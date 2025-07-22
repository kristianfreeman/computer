# Nix config
# Kristian Freeman / kristianfreeman.com
# Created 2024-11-08

# Tested with https://determinate.systems installer

# Sources that helped me set this up:
#  - https://davi.sh/blog/2024/01/nix-darwin/
#  - https://nixcademy.com/posts/nix-on-macos/
#  - https://github.com/mirkolenz/nixos/blob/main/system/darwin/settings.nix

{
  description = "Kristian Freeman system config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur.url = "github:nix-community/NUR";
  };

  outputs = inputs @ { self, nix-darwin, nixpkgs, nix-homebrew, home-manager, nur, ... }:

  let
    commonHomeConfig = import ./home/common.nix;

    inherit (nixpkgs) lib;

    macBilboConfiguration = { config, pkgs, ... }:
      import ./hosts/bilbo/configuration.nix { 
        inherit config pkgs;
      };

    drumConfiguration = { config, pkgs, ... }:
      import ./hosts/drum/configuration.nix { 
        inherit config pkgs;
      };

    macCFConfiguration = { config, pkgs, ... }:
      import ./hosts/cf/configuration.nix { 
        inherit config pkgs;
      };

    macGandalfConfiguration = { config, pkgs, ... }:
      import ./hosts/gandalf/configuration.nix { 
        inherit config pkgs;
      };

    nixosConfiguration = { config, pkgs, ... }:
      import ./hosts/nas/configuration.nix {
        inherit config pkgs;
      };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#bilbo
    darwinConfigurations.bilbo = nix-darwin.lib.darwinSystem {
      modules = [
        # TODO: fix this
        # ({ config, pkgs, ... }: {
        #   system.configurationRevision = self.rev or self.dirtyRev or null;
        # })
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ nur.overlays.default ];
        })
        macBilboConfiguration
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.kristian = commonHomeConfig;
        }
      ];
    };

    darwinConfigurations.drum = nix-darwin.lib.darwinSystem {
      modules = [
        # TODO: fix this
        # ({ config, pkgs, ... }: {
        #   system.configurationRevision = self.rev or self.dirtyRev or null;
        # })
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ nur.overlays.default ];
        })
        drumConfiguration
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.kristian = commonHomeConfig;
        }
      ];
    };

    darwinConfigurations.gandalf = nix-darwin.lib.darwinSystem {
      modules = [
        # TODO: fix this
        # ({ config, pkgs, ... }: {
        #   system.configurationRevision = self.rev or self.dirtyRev or null;
        # })
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ nur.overlays.default ];
        })
        macGandalfConfiguration
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.kristian = commonHomeConfig;
        }
      ];
    };

    darwinConfigurations.JNVX4K0VCG = nix-darwin.lib.darwinSystem {
      modules = [
        # TODO: fix this
        # ({ config, pkgs, ... }: {
        #   system.configurationRevision = self.rev or self.dirtyRev or null;
        # })
        ({ config, pkgs, ... }: {
          nixpkgs.overlays = [ nur.overlays.default ];
        })
        macCFConfiguration
        nix-homebrew.darwinModules.nix-homebrew
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.verbose = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.kristian = commonHomeConfig;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations.bilbo.pkgs;

    nixosConfigurations.nas = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        nasConfiguration
        home-manager.nixosModules.home-manager {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.kristian = commonHomeConfig;
        }
      ];
    };
  };
}
