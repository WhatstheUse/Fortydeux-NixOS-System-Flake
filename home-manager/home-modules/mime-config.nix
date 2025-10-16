{ config, pkgs, ... }:

{
  # Enhanced MIME type configuration to fix app chooser issues
  xdg.mimeApps = {
    enable = true;
    
    # Default applications for common file types
    defaultApplications = {
      # Web browsers
      "text/html" = [ "firefox.desktop" ];
      "x-scheme-handler/http" = [ "firefox.desktop" ];
      "x-scheme-handler/https" = [ "firefox.desktop" ];
      "x-scheme-handler/about" = [ "firefox.desktop" ];
      "x-scheme-handler/unknown" = [ "firefox.desktop" ];
      
      # File manager
      "inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      
      # Text files
      "text/plain" = [ "code.desktop" "cursor.desktop" "helix.desktop" ];
      "text/x-readme" = [ "code.desktop" "cursor.desktop" ];
      "text/markdown" = [ "code.desktop" "cursor.desktop" ];
      
      # Code files
      "text/x-python" = [ "code.desktop" "cursor.desktop" ];
      "text/x-rust" = [ "code.desktop" "cursor.desktop" ];
      "text/x-nix" = [ "code.desktop" "cursor.desktop" ];
      "application/x-shellscript" = [ "code.desktop" "cursor.desktop" ];
      "text/x-c" = [ "code.desktop" "cursor.desktop" ];
      "text/x-cpp" = [ "code.desktop" "cursor.desktop" ];
      "text/x-javascript" = [ "code.desktop" "cursor.desktop" ];
      "text/x-typescript" = [ "code.desktop" "cursor.desktop" ];
      "application/json" = [ "code.desktop" "cursor.desktop" ];
      "application/x-yaml" = [ "code.desktop" "cursor.desktop" ];
      "text/x-toml" = [ "code.desktop" "cursor.desktop" ];
      
      # Documents
      "application/pdf" = [ "okular.desktop" "firefox.desktop" ];
      "application/vnd.oasis.opendocument.text" = [ "libreoffice-writer.desktop" ];
      "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = [ "libreoffice-writer.desktop" ];
      "application/vnd.ms-excel" = [ "libreoffice-calc.desktop" ];
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = [ "libreoffice-calc.desktop" ];
      
      # Images
      "image/jpeg" = [ "org.kde.gwenview.desktop" "firefox.desktop" ];
      "image/png" = [ "org.kde.gwenview.desktop" "firefox.desktop" ];
      "image/gif" = [ "org.kde.gwenview.desktop" "firefox.desktop" ];
      "image/webp" = [ "org.kde.gwenview.desktop" "firefox.desktop" ];
      "image/svg+xml" = [ "org.kde.gwenview.desktop" "firefox.desktop" ];
      "image/tiff" = [ "org.kde.gwenview.desktop" "firefox.desktop" ];
      "image/bmp" = [ "org.kde.gwenview.desktop" "firefox.desktop" ];
      
      # Audio
      "audio/mpeg" = [ "mpv.desktop" ];
      "audio/flac" = [ "mpv.desktop" ];
      "audio/x-vorbis+ogg" = [ "mpv.desktop" ];
      "audio/mp4" = [ "mpv.desktop" ];
      "audio/wav" = [ "mpv.desktop" ];
      "audio/x-wav" = [ "mpv.desktop" ];
      "audio/aac" = [ "mpv.desktop" ];
      "audio/x-m4a" = [ "mpv.desktop" ];
      
      # Video
      "video/mp4" = [ "mpv.desktop" ];
      "video/x-matroska" = [ "mpv.desktop" ];
      "video/webm" = [ "mpv.desktop" ];
      "video/quicktime" = [ "mpv.desktop" ];
      "video/x-msvideo" = [ "mpv.desktop" ];
      "video/x-ms-wmv" = [ "mpv.desktop" ];
      "video/mpeg" = [ "mpv.desktop" ];
      "video/ogg" = [ "mpv.desktop" ];
      
      # Archives
      "application/zip" = [ "org.kde.ark.desktop" ];
      "application/x-tar" = [ "org.kde.ark.desktop" ];
      "application/x-7z-compressed" = [ "org.kde.ark.desktop" ];
      "application/x-rar-compressed" = [ "org.kde.ark.desktop" ];
      "application/x-bzip2" = [ "org.kde.ark.desktop" ];
      "application/x-gzip" = [ "org.kde.ark.desktop" ];
      "application/x-xz" = [ "org.kde.ark.desktop" ];
      
      # VS Code and Cursor URL handlers
      "x-scheme-handler/vscode" = [ "vscode-url-handler.desktop" ];
      "x-scheme-handler/vscode-insiders" = [ "vscode-url-handler.desktop" ];
      "x-scheme-handler/cursor" = [ "cursor-url-handler.desktop" ];
      "x-scheme-handler/cursor-insiders" = [ "cursor-url-handler.desktop" ];
      
      # Email
      "x-scheme-handler/mailto" = [ "org.kde.kmail2.desktop" ];
      
      # Calendar
      "x-scheme-handler/webcal" = [ "org.kde.korganizer.desktop" ];
      
      # Terminal
      "application/x-terminal-emulator" = [ "kitty.desktop" ];
    };
    
    # Applications to add to specific MIME types
    associations.added = {
      # Multiple text editors for flexibility
      "text/plain" = [ "code.desktop" "cursor.desktop" "helix.desktop" "vim.desktop" ];
      "text/x-nix" = [ "code.desktop" "cursor.desktop" "helix.desktop" ];
      
      # Multiple image viewers
      "image/jpeg" = [ "org.kde.gwenview.desktop" "firefox.desktop" "gimp.desktop" ];
      "image/png" = [ "org.kde.gwenview.desktop" "firefox.desktop" "gimp.desktop" ];
      
      # Multiple media players
      "audio/mpeg" = [ "mpv.desktop" "vlc.desktop" ];
      "video/mp4" = [ "mpv.desktop" "vlc.desktop" ];
      
      # Multiple file managers
      "inode/directory" = [ "org.gnome.Nautilus.desktop" "thunar.desktop" ];
      
      # Multiple PDF viewers
      "application/pdf" = [ "okular.desktop" "firefox.desktop" ];
    };
    
    # Applications to remove from specific MIME types (if needed)
    associations.removed = {
      # Remove problematic associations that cause empty chooser
      "text/html" = [ "org.kde.discover.desktop" ];
      "x-scheme-handler/http" = [ "org.kde.discover.desktop" ];
      "x-scheme-handler/https" = [ "org.kde.discover.desktop" ];
    };
  };
  
  # Additional desktop entries for better integration
  xdg.desktopEntries = {
    # Enhanced file manager entry
    file-manager = {
      name = "File Manager";
      exec = "nautilus %F";
      icon = "folder";
      type = "Application";
      categories = [ "System" "FileManager" ];
      mimeType = [ "inode/directory" ];
    };
    vscode-url-handler = {
      name = "VS Code URL Handler";
      exec = "code --open-url %U";
      icon = "vscode";
      type = "Application";
      noDisplay = true;
      mimeType = [ "x-scheme-handler/vscode" "x-scheme-handler/vscode-insiders" ];
    };
    cursor-url-handler = {
      name = "Cursor URL Handler";
      exec = "cursor --open-url %U";
      icon = "cursor";
      type = "Application";
      noDisplay = true;
      mimeType = [ "x-scheme-handler/cursor" "x-scheme-handler/cursor-insiders" ];
    };
    
    # Enhanced terminal entry
    terminal = {
      name = "Terminal";
      exec = "kitty";
      icon = "terminal";
      type = "Application";
      categories = [ "System" "TerminalEmulator" ];
      mimeType = [ "application/x-terminal-emulator" ];
    };
  };
}
