{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [ pkgs.vim
          pkgs.ollama
          pkgs.zoxide
          pkgs.fzf
          pkgs.fzf-zsh
          pkgs.rustc
          pkgs.rustup
          pkgs.oh-my-zsh
        ];
      services.nix-daemon.enable = true;
      
      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;
	    programs.zsh.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      security.pam.enableSudoTouchIdAuth = true;
      
      system.defaults = {
          dock.autohide = true;
          dock.mru-spaces = false;
          dock.persistent-apps = [
            "/Applications/Brave Browser.app"
            "/Applications/Ghostty.app"
            "/Applications/Obsidian.app"
            "/Applications/Telegram.app"
            "/Applications/Visual Studio Code.app"
            "/Applications/LM Studio.app"
            "/System/Applications/iPhone Mirroring.app"
          ];
          dock.show-recents = false;
          dock.tilesize = 24;
          dock.wvous-bl-corner = 1;
          dock.wvous-br-corner = 1;
          dock.wvous-tl-corner = 1;
          dock.wvous-tr-corner = 1;
          finder.AppleShowAllExtensions = true;
          finder.FXPreferredViewStyle = "Nlsv";
          finder.ShowPathbar = true;
          finder.ShowStatusBar = true;
          hitoolbox.AppleFnUsageType = "Change Input Source";
          
          screensaver.askForPasswordDelay = 10;

        };


      # Mac only block
      homebrew.enable = true;
      homebrew.casks = [
	      "visual-studio-code"
        "orbstack"
        "1password"
        "1password-cli"
        "raycast"
        "ghostty"
        "obsidian"
        "lm-studio"
      ];
      homebrew.brews = [
	      "imagemagick"
        "uv"
        "node"
        "ollama"
        "rclone"
        "gnupg"
        "stow"
      ];
      homebrew.masApps = {
	      Telegram = 747648890;
	    };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#sp_macos
    darwinConfigurations."sp_macos" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
