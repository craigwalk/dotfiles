{
  description = "Example Darwin system flake";

  nixConfig = {
    allowUnfree = true;
    experimental-features = ["nix-command" "flakes"];
      };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

  };
  
  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:

  let

    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget

    

      environment.systemPackages =
        [
          # vim
          pkgs.vim
          # https://github.com/nektos/act 
          pkgs.act
          # docker-machine drop in
          pkgs.docker
          pkgs.docker-compose
          pkgs.colima
          pkgs.qemu
          pkgs.tmux
          pkgs.playwright
          pkgs.tldr
          # Finds commands that aren't installed
          pkgs.comma
          pkgs.autorestic
          pkgs.rancher

        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
    
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Craigs-Laptop
    darwinConfigurations."Craigs-Laptop" = nix-darwin.lib.darwinSystem {
      
      modules = [ configuration,
        nix-homebrew.darwinModules.nix-homebrew ];
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = "craig";

            # Automatically migrate existing Homebrew installations
            autoMigrate = true;
            # /run/current-system/sw/bin is here the packages are linked
          };
        }
    

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."Craigs-Laptop".pkgs;
  };
}
