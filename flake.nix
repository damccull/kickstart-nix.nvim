{
  description = "damccull neovim kickstart";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    gen-luarc.url = "github:mrcjkb/nix-gen-luarc-json";

    # Add bleeding-edge plugins here.
    # They can be updated with `nix flake update` (make sure to commit the generated flake.lock)
    # wf-nvim = {
    #   url = "github:Cassin01/wf.nvim";
    #   flake = false;
    # };
    eyeliner-nvim-pinned = {
      url = "github:jinh0/eyeliner.nvim/7385c1a29091b98ddde186ed2d460a1103643148";
      flake = false;
    };
    web-tools = {
      url = "github:ray-x/web-tools.nvim";
      flake = false;
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      systems = builtins.attrNames nixpkgs.legacyPackages;

      # This is where the Neovim derivation is built.
      neovim-overlay = import ./nix/neovim-overlay.nix { inherit inputs; };
    in
    flake-utils.lib.eachSystem systems (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            # Import the overlay, so that the final Neovim derivation(s) can be accessed via pkgs.<nvim-pkg>
            neovim-overlay
            # This adds a function can be used to generate a .luarc.json
            # containing the Neovim API all plugins in the workspace directory.
            # The generated file can be symlinked in the devShell's shellHook.
            inputs.gen-luarc.overlays.default
          ];
        };

        # Extrack the plugin store paths resolved by neovim-overlay
        myPlugins = pkgs.nvim-plugins or [ ];

        shell = pkgs.mkShell {
          name = "nvim-devShell";
          buildInputs = with pkgs; [
            # Tools for Lua and Nix development, useful for editing files in this repo
            lua-language-server
            nil
            stylua
            luajitPackages.luacheck
            nixpkgs-fmt
            nvim-dev
          ];
          shellHook = ''
            # symlink the .luarc.json generated in the overlay
            ln -fs ${pkgs.nvim-luarc-json} .luarc.json
            # allow quick iteration of the lua configs
            ln -Tfns $PWD/nvim ~/.config/nvim-dev
          '';
        };
      in
      {
        packages = rec {
          default = nvim;
          nvim = pkgs.nvim-pkg;
          bundle-pack =
            pkgs.runCommand "nvim-portable-bundle"
              {
                nativeBuildInputs = [
                  pkgs.gnutar
                  pkgs.gzip
                ];
              }
              ''
                mkdir -p $out
                BUILD_DIR=$(mktemp -d)

                # 1. Structure the runtime config (~/.config/nvim content)
                mkdir -p $BUILD_DIR/.config/nvim
                cp -r ${./nvim}/* $BUILD_DIR/.config/nvim/

                # 2. Structure the plugins into the native pack directory (~/.local/share/nvim content)
                PACK_DIR=$BUILD_DIR/.local/share/nvim/site/pack/bundle/start
                mkdir -p $PACK_DIR

                # Loop through the store paths of the plugins built by the Nix overlay
                # and symlink or copy them into the native structure
                for plugin in ${pkgs.lib.escapeShellArgs myPlugins}; do
                  plugin_name=$(basename "$plugin")
                  # Strip the nix hash prefix from the directory name for a clean pack folder
                  clean_name=$(echo "$plugin_name" | sed -r 's/^[a-z0-9]{32}-//')
                  cp -r "$plugin" "$PACK_DIR/$clean_name"
                  chmod -R +w "$PACK_DIR/$clean_name"
                done

                # 3. Pack it all up into a single, portable archive
                tar -czf $out/nvim-bundle.tar.gz -C $BUILD_DIR .config .local
              '';
        };
        devShells = {
          default = shell;
        };
      }
    )
    // {
      # You can add this overlay to your NixOS configuration
      overlays.default = neovim-overlay;
    };
}
