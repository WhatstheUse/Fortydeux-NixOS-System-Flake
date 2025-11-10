{ config, pkgs, inputs, username, ... }:

{
  imports = [
    ./oatmeal.nix
  ];

  home.packages = (with pkgs; [
    aichat #LLMs in the command line with repl, sessions, etc. 
    alpaca #GTK4 app for Ollama and local LLM interaction
    appflowy #An open-source alternative to Notion - now with AI drafting features
    code-cursor #AI-powered code editor built on vscode
    codex #OpenAI lightweight coding agent that runs in terminal
    claude-code #Agentic coding tool for terminal and codebase
    tenere #Rust-based TUI for interacting with AI LLMs
    warp-terminal #Modern rust-based AI-enabled terminal       
    waveterm  #Paneled Terminal, File-Manager w/ Preview, AI chat, and Webviewer
    windsurf #Agentic IDE powered by AI Flow paradigm
    zed-editor #Modern text editor with AI built in - still in development for Linux
  ]);

  programs.fabric-ai = {
    enable = true;
  };
}
