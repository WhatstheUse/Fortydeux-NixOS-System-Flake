{ config, lib, pkgs, ... }:
let
  whisperPkg = pkgs.whisper-cpp;
  
  # Shared Python env - includes all packages needed by both whisper systems  
  pyEnvWhisper = pkgs.python313.withPackages (ps: with ps; [
    faster-whisper   # for faster-whisper daemon (unused here but prevents conflicts)
    sounddevice      # for real-time audio capture (both systems)
    soundfile        # for reading wavs (both systems)
    numpy           # for audio processing (both systems)
  ]);

  # WhisperCPP Daemon
  whisper-cpp-daemon = pkgs.writeShellScriptBin "whisper-cpp-daemon" ''
    export WHISPER_MODEL="${config.services.dictation-whispercpp.model}"
    export WHISPER_MODEL_PATH="${config.services.dictation-whispercpp.modelPath}"
    export WHISPER_LANGUAGE="${config.services.dictation-whispercpp.language}"
    
    echo "DEBUG: WHISPER_MODEL=$WHISPER_MODEL" >&2
    echo "DEBUG: WHISPER_MODEL_PATH=$WHISPER_MODEL_PATH" >&2
    echo "DEBUG: Model file exists: $([ -f "$WHISPER_MODEL_PATH" ] && echo yes || echo no)" >&2
    
    exec ${pyEnvWhisper}/bin/python - << 'DAEMON_PY'
#!/usr/bin/env python3
"""
Real-time whisper.cpp transcription daemon.
Uses whisper.cpp CLI with persistent audio recording.
"""

import asyncio
import os
import subprocess
import sys
import tempfile
import time
import numpy as np
import sounddevice as sd
import soundfile as sf

class WhisperCppDaemon:
    def __init__(self, model_path, language="en"):
        self.model_path = model_path
        self.language = language
        self.socket_path = "/tmp/whisper-cpp-daemon.sock"
        self.recording = False
        self.processing = False
        self.audio_buffer = []
        self.sample_rate = 16000
        self.min_audio_length = 0.5
        self.start_time = time.time()
        
        # Logging setup with rotation
        self.log_path = "/tmp/whisper-cpp-daemon.log"
        self._rotate_log_if_needed()
        self.log_file = open(self.log_path, "a")
        
    def log(self, message):
        timestamp = time.strftime("%Y-%m-%d %H:%M:%S")
        print(f"[{timestamp}] {message}", file=self.log_file, flush=True)
        
    def debug(self, message):
        if os.environ.get("WHISPER_DEBUG"):
            self.log(f"DEBUG: {message}")
            
    def _rotate_log_if_needed(self):
        """Rotate log file if it gets too large (>1MB)."""
        try:
            if os.path.exists(self.log_path) and os.path.getsize(self.log_path) > 1024 * 1024:
                backup_path = f"{self.log_path}.old"
                if os.path.exists(backup_path):
                    os.unlink(backup_path)
                os.rename(self.log_path, backup_path)
        except Exception:
            pass
            
    def start_recording(self):
        """Start audio recording."""
        if self.recording:
            self.debug("Already recording, ignoring start command")
            return
            
        self.log("Starting recording")
        self.recording = True
        self.audio_buffer = []
        
        def record_callback(indata, frames, time, status):
            if status:
                self.debug(f"Audio callback status: {status}")
            if self.recording:
                self.audio_buffer.append(indata.copy())
                
        try:
            self.stream = sd.InputStream(
                samplerate=self.sample_rate,
                channels=1,
                dtype=np.float32,
                callback=record_callback,
                blocksize=512,
                device=None
            )
            self.stream.start()
            self.debug("Audio stream started")
        except Exception as e:
            self.log(f"Failed to start recording: {e}")
            self.recording = False
            
    def stop_recording_and_transcribe(self):
        """Stop recording and transcribe via whisper.cpp."""
        if not self.recording:
            self.debug("Not recording, ignoring stop command")
            return ""
            
        self.log("Transcribing")
        self.recording = False
        self.processing = True
        
        try:
            self.stream.stop()
            self.stream.close()
        except Exception as e:
            self.log(f"Error stopping stream: {e}")
            
        if not self.audio_buffer:
            self.debug("No audio data recorded")
            return ""
            
        # Concatenate audio buffer
        audio_data = np.concatenate(self.audio_buffer, axis=0)
        duration = len(audio_data) / self.sample_rate
        self.debug(f"Recorded {len(audio_data)} samples ({duration:.2f}s)")
        
        # Skip transcription if too short
        if duration < self.min_audio_length:
            self.debug(f"Audio too short ({duration:.2f}s), skipping")
            self.processing = False
            return ""
            
        # Memory safety: limit max recording length to 60 seconds
        max_samples = 60 * self.sample_rate
        if len(audio_data) > max_samples:
            self.log(f"Recording too long ({duration:.1f}s), truncating to 60s")
            audio_data = audio_data[-max_samples:]
        
        # Save to temporary file for whisper.cpp
        with tempfile.NamedTemporaryFile(suffix=".wav", delete=False) as tmp_file:
            sf.write(tmp_file.name, audio_data, self.sample_rate)
            
            try:
                # Transcribe with whisper.cpp CLI
                self.debug("Starting transcription")
                result = subprocess.run([
                    "${lib.getExe whisperPkg}",
                    "-m", self.model_path,
                    "-f", tmp_file.name,
                    "-l", self.language,
                    "-nt",  # no timestamps
                    "-np",  # no progress
                ], capture_output=True, text=True, timeout=30)
                
                if result.returncode == 0:
                    text = result.stdout.strip()
                    self.log(f"Result: '{text}'")
                    self.processing = False
                    return text
                else:
                    self.log(f"whisper.cpp failed: {result.stderr}")
                    self.processing = False
                    return ""
                    
            except Exception as e:
                self.log(f"Transcription failed: {e}")
                self.processing = False
                return ""
            finally:
                # Clean up temp file and audio buffer
                try:
                    os.unlink(tmp_file.name)
                except:
                    pass
                # Clear buffer to prevent memory leaks
                self.audio_buffer = []
                    
    async def handle_client(self, reader, writer):
        """Handle client connections via Unix socket."""
        try:
            data = await reader.read(1024)
            command = data.decode().strip()
            self.log(f"Received command: {command}")
            
            if command == "start":
                self.start_recording()
                response = "ok"
            elif command == "stop":
                result = self.stop_recording_and_transcribe()
                response = result if result else "no_result"
            elif command == "status":
                uptime = time.time() - self.start_time
                if self.processing:
                    status = "processing"
                elif self.recording:
                    status = "recording"
                else:
                    status = "idle"
                response = f"{status} (uptime: {uptime/3600:.1f}h)"
                
                # Auto-shutdown after 24 hours
                if uptime > 24 * 3600:
                    self.log("Auto-shutdown after 24h uptime")
                    response = "shutting_down_old"
                    writer.write(response.encode())
                    await writer.drain()
                    writer.close()
                    await writer.wait_closed()
                    os._exit(0)
            elif command == "shutdown":
                self.log("Shutdown requested")
                response = "ok"
                writer.write(response.encode())
                await writer.drain()
                writer.close()
                await writer.wait_closed()
                os._exit(0)
            else:
                response = "unknown_command"
                
            self.log(f"Sending response: {response[:50]}...")
            writer.write(response.encode())
            await writer.drain()
            writer.close()
            await writer.wait_closed()
            
        except Exception as e:
            self.log(f"Error handling client: {e}")
            
    async def run_server(self):
        """Run the Unix socket server."""
        # Clean up any existing socket
        try:
            os.unlink(self.socket_path)
        except FileNotFoundError:
            pass
            
        # Ensure socket directory exists
        os.makedirs(os.path.dirname(self.socket_path), exist_ok=True)
            
        server = await asyncio.start_unix_server(
            self.handle_client,
            path=self.socket_path
        )
        
        self.log(f"Listening on {self.socket_path}")
        
        async with server:
            await server.serve_forever()
            
    async def run(self):
        """Main daemon loop."""
        self.log("WhisperCpp daemon starting")
        await self.run_server()

def main():
    model_name = os.environ.get("WHISPER_MODEL", "tiny")
    model_path = os.environ.get("WHISPER_MODEL_PATH", "")
    language = os.environ.get("WHISPER_LANGUAGE", "en")
    
    if not model_path or not os.path.exists(model_path):
        print(f"Error: Model file not found at {model_path}", file=sys.stderr)
        print(f"Run whisper-cpp-download-ggml-model {model_name}.en to download", file=sys.stderr)
        sys.exit(1)
    
    daemon = WhisperCppDaemon(model_path, language)
    
    try:
        asyncio.run(daemon.run())
    except KeyboardInterrupt:
        daemon.log("Daemon shutdown requested")
    except Exception as e:
        daemon.log(f"Daemon crashed: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
DAEMON_PY
  '';

  # Legacy CLI wrapper (keep for compatibility)
  wcpp-transcribe = pkgs.writeShellScriptBin "wcpp-transcribe" ''
    set -euo pipefail
    IN="$1"
    MODEL="${config.services.dictation-whispercpp.modelPath}"
    LANG="${config.services.dictation-whispercpp.language}"

    # Run whisper.cpp CLI and write a .txt sidecar in /tmp
    "${lib.getExe whisperPkg}" \
      -m "$MODEL" \
      -f "$IN" \
      -l "$LANG" \
      -otxt \
      -of /tmp/wcpp-out >/dev/null

    # Emit transcript to stdout
    cat /tmp/wcpp-out.txt | tr -d '\r'
  '';
  # New daemon-based scripts
  dictate-wc-ptt-start = pkgs.writeShellScriptBin "dictate-wc-ptt-start" ''
    SOCKET="/tmp/whisper-cpp-daemon.sock"
    MODEL_PATH="${config.services.dictation-whispercpp.modelPath}"
    

    
    # Check if daemon is running and responsive
    if [ ! -S "$SOCKET" ] || ! echo "status" | ${pkgs.socat}/bin/socat -T 2 - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1; then
      # Auto-setup model if missing (one-time setup)
      if [ ! -f "$MODEL_PATH" ]; then
        echo "Setting up whisper model (one-time setup)..." >&2
        mkdir -p "$(dirname "$MODEL_PATH")"
        cd "$(dirname "$MODEL_PATH")"
        ${whisperPkg}/bin/whisper-cpp-download-ggml-model ${config.services.dictation-whispercpp.model}.en >&2
      fi
      
      echo "Starting whisper-cpp daemon..." >&2
      # Clean up any stale processes
      pkill -f whisper-cpp-daemon || true
      rm -f "$SOCKET"
      
      ${whisper-cpp-daemon}/bin/whisper-cpp-daemon &
      # Wait for socket to appear and be responsive
      for i in 1 2 3 4 5 6 7 8 9 10; do
        if [ -S "$SOCKET" ] && echo "status" | ${pkgs.socat}/bin/socat -T 2 - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1; then
          break
        fi
        sleep 0.5
      done
      if [ ! -S "$SOCKET" ]; then
        echo "Failed to start daemon" >&2
        exit 1
      fi
    fi
    
    # Send start command
    echo "start" | ${pkgs.socat}/bin/socat -T 5 - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1
  '';

  dictate-wc-ptt-stop = pkgs.writeShellScriptBin "dictate-wc-ptt-stop" ''
    SOCKET="/tmp/whisper-cpp-daemon.sock"
    
    # Check if daemon is running and responsive
    if [ ! -S "$SOCKET" ] || ! echo "status" | ${pkgs.socat}/bin/socat -T 2 - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1; then
      echo "Whisper-cpp daemon not responsive" >&2
      exit 1
    fi
    
    # Send stop command and get transcription result (with timeout)
    TEXT="$(echo "stop" | ${pkgs.socat}/bin/socat -T 30 -t 30 - UNIX-CONNECT:"$SOCKET" | head -1)"
    
    # Type the result if not empty
    if [ -n "$TEXT" ] && [ "$TEXT" != "ok" ] && [ "$TEXT" != "no_result" ]; then
      ${pkgs.wtype}/bin/wtype -- "$TEXT"
    fi
  '';
  
  # Daemon management scripts
  whisper-cpp-daemon-start = pkgs.writeShellScriptBin "whisper-cpp-daemon-start" ''
    SOCKET="/tmp/whisper-cpp-daemon.sock"
    MODEL_PATH="${config.services.dictation-whispercpp.modelPath}"
    
    if [ -S "$SOCKET" ]; then
      echo "Daemon already running"
      exit 0
    fi
    
    # Auto-setup model if missing (one-time setup)
    if [ ! -f "$MODEL_PATH" ]; then
      echo "Setting up whisper model (one-time setup)..." >&2
      mkdir -p "$(dirname "$MODEL_PATH")"
      cd "$(dirname "$MODEL_PATH")"
      ${whisperPkg}/bin/whisper-cpp-download-ggml-model ${config.services.dictation-whispercpp.model}.en >&2
    fi
    
    echo "Starting whisper-cpp daemon..."
    ${whisper-cpp-daemon}/bin/whisper-cpp-daemon &
  '';
  
  whisper-cpp-daemon-stop = pkgs.writeShellScriptBin "whisper-cpp-daemon-stop" ''
    SOCKET="/tmp/whisper-cpp-daemon.sock"
    if [ -S "$SOCKET" ]; then
      echo "shutdown" | ${pkgs.socat}/bin/socat - UNIX-CONNECT:"$SOCKET" >/dev/null 2>&1
      sleep 1
      rm -f "$SOCKET"
    fi
    pkill -f whisper-cpp-daemon || true
  '';

  # Toggle script for single keybinding
  dictate-wc-ptt-toggle = pkgs.writeShellScriptBin "dictate-wc-ptt-toggle" ''
    SOCKET="/tmp/whisper-cpp-daemon.sock"
    
    # Check daemon status
    if [ -S "$SOCKET" ]; then
      STATUS="$(echo "status" | ${pkgs.socat}/bin/socat -T 2 - UNIX-CONNECT:"$SOCKET" 2>/dev/null || echo "idle")"
      if [[ "$STATUS" == *"recording"* ]]; then
        # Currently recording, so stop
        ${dictate-wc-ptt-stop}/bin/dictate-wc-ptt-stop
      else
        # Not recording, so start
        ${dictate-wc-ptt-start}/bin/dictate-wc-ptt-start
      fi
    else
      # Daemon not running, start recording
      ${dictate-wc-ptt-start}/bin/dictate-wc-ptt-start
    fi
  '';

  # Auto-stop recording after timeout (push-to-talk style)
  dictate-wc-ptt-auto = pkgs.writeShellScriptBin "dictate-wc-ptt-auto" ''
    SOCKET="/tmp/whisper-cpp-daemon.sock"
    TIMEOUT=''${1:-5}  # Default 5 seconds, or pass as argument
    
    # Start recording
    ${dictate-wc-ptt-start}/bin/dictate-wc-ptt-start
    
    # Wait for timeout, then stop
    sleep "$TIMEOUT"
    ${dictate-wc-ptt-stop}/bin/dictate-wc-ptt-stop
  '';

in
{
  options.services.dictation-whispercpp = {
    enable = lib.mkEnableOption "Local push-to-talk dictation via whisper.cpp";
    model = lib.mkOption {
      type = lib.types.str;
      default = "tiny";
      example = "small";
      description = "Whisper model size (tiny|base|small|medium|large-v3). Auto-downloads if not found.";
    };
    modelPath = lib.mkOption {
      type = lib.types.str;
      default = "$HOME/.local/share/whisper/ggml-${config.services.dictation-whispercpp.model}.en.bin";
      example = "/home/you/models/ggml-medium.bin";
      description = "Path to ggml/gguf Whisper model file. Auto-derived from model option.";
    };
    language = lib.mkOption {
      type = lib.types.str;
      default = "en";
      description = "Language code for transcription.";
    };
  };

  config = lib.mkIf config.services.dictation-whispercpp.enable {
    home.packages = with pkgs; [
      wtype
      socat   # for Unix socket communication
      whisperPkg

      whisper-cpp-daemon
      whisper-cpp-daemon-start
      whisper-cpp-daemon-stop
      dictate-wc-ptt-start
      dictate-wc-ptt-stop
      dictate-wc-ptt-toggle
      dictate-wc-ptt-auto
      # Legacy tools (keep for compatibility)
      wcpp-transcribe
    ] ++ lib.optionals (!config.services.dictation-faster.enable) [
      # Only install Python env if faster-whisper isn't also enabled (to avoid conflicts)
      pyEnvWhisper
    ];
  };
}
