# This overlay, when applied to nixpkgs, adds the final neovim derivation to nixpkgs.
{ inputs }:
final: prev:
with final.pkgs.lib;
let
  pkgs = final;

  # Use this to create a plugin from a flake input
  mkNvimPlugin =
    src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
    };

  # Use this to create a plugin from a flake input
  mkNvimPluginNoShebangs =
    src: pname:
    pkgs.vimUtils.buildVimPlugin {
      inherit pname src;
      version = src.lastModifiedDate;
      dontPatchShebangs = true;
    };

  # Make sure we use the pinned nixpkgs instance for wrapNeovimUnstable,
  # otherwise it could have an incompatible signature when applying this overlay.
  pkgs-locked = inputs.nixpkgs.legacyPackages.${pkgs.stdenv.hostPlatform.system};

  # This is the helper function that builds the Neovim derivation.
  mkNeovim = pkgs.callPackage ./mkNeovim.nix {
    inherit (pkgs-locked) wrapNeovimUnstable neovimUtils;
  };

  # A plugin can either be a package or an attrset, such as
  # { plugin = <plugin>; # the package, e.g. pkgs.vimPlugins.nvim-cmp
  #   config = <config>; # String; a config that will be loaded with the plugin
  #   # Boolean; Whether to automatically load the plugin as a 'start' plugin,
  #   # or as an 'opt' plugin, that can be loaded with `:packadd!`
  #   optional = <true|false>; # Default: false
  #   ...
  # }
  my-plugins = with pkgs.vimPlugins; [
    # Treesitter plugins
    nvim-treesitter.withAllGrammars # Treesitter syntax highlighting with all grammars
    nvim-treesitter-textobjects # textobjects plugin for treesitter
    nvim-treesitter-context # Treesitter | nvim-treesitter-context
    nvim-ts-context-commentstring # https://github.com/joosepalviste/nvim-ts-context-commentstring/
    # ^ Treesitter plugins

    luasnip # snippets | https://github.com/l3mon4d3/luasnip/

    # nvim-cmp (autocompletion) and extensions
    nvim-cmp # https://github.com/hrsh7th/nvim-cmp
    cmp_luasnip # snippets autocompletion extension for nvim-cmp | https://github.com/saadparwaiz1/cmp_luasnip/
    lspkind-nvim # vscode-like LSP pictograms | https://github.com/onsails/lspkind.nvim/
    cmp-nvim-lsp # LSP as completion source | https://github.com/hrsh7th/cmp-nvim-lsp/
    cmp-nvim-lsp-signature-help # https://github.com/hrsh7th/cmp-nvim-lsp-signature-help/
    cmp-buffer # current buffer as completion source | https://github.com/hrsh7th/cmp-buffer/
    cmp-path # file paths as completion source | https://github.com/hrsh7th/cmp-path/
    cmp-nvim-lua # neovim lua API as completion source | https://github.com/hrsh7th/cmp-nvim-lua/
    cmp-cmdline # cmp command line suggestions
    cmp-cmdline-history # cmp command line history suggestions
    # ^ nvim-cmp extensions

    # git integrations
    gitsigns-nvim # Adds git related signs to the gutter and utilities for managing changes
    diffview-nvim # https://github.com/sindrets/diffview.nvim
    neogit # https://github.com/TimUntersberger/neogit
    vim-fugitive # https://github.com/tpope/vim-fugitive
    # ^ git integrations

    # Telescope and extensions
    telescope-nvim # Fuzzy finder for files, lsp, etc
    telescope-fzy-native-nvim
    telescope-ui-select-nvim # Telescope
    # telescope-smart-history-nvim # https://github.com/nvim-telescope/telescope-smart-history.nvim
    # ^ Telescope and extensions

    # UI
    fidget-nvim # UI for Neovim notifications and LSP status/progress
    lualine-nvim # Status line | https://github.com/nvim-lualine/lualine.nvim/
    nvim-navic # Lualine | Add LSP location to lualine | https://github.com/SmiteshP/nvim-navic nvim-web-devicons # Telescope
    statuscol-nvim # Status column | https://github.com/luukvbaal/statuscol.nvim
    todo-comments-nvim # Highlight TODO and similar comments
    which-key-nvim # Shows a menu of keybinds

    # eyeliner-nvim # Highlights unique characters for f/F and t/T motions | https://github.com/jinh0/eyeliner.nvim
    (mkNvimPlugin inputs.eyeliner-nvim-pinned "eyeliner.nvim")
    # ^ UI

    # Language support
    rustaceanvim # Rust ide capability
    # ^ Language support

    # Navigation and editing enhancements
    comment-nvim # Allows commenting visual regions or lines
    conform-nvim # Autoformatting
    indent-blankline-nvim
    mini-surround # Consider removing this in favor of mini.statusline
    nvim-autopairs
    nvim-unception # Prevent nested neovim sessions
    (mkNvimPlugin inputs.web-tools "web-tools.nvim") # Web editing
    # ^ Navigation and editing enhancements

    # Themes
    kanagawa-nvim
    # ^ Themes

    # Dependencies of other plugins - without lazyvim these aren't installed magically
    nvim-web-devicons
    plenary-nvim # Telescope
    sqlite-lua
    vim-repeat
    # ^ Dependencies
  ];

  extraPackages = with pkgs; [
    # language servers, etc.
    lua-language-server
    nil # nix LSP
    nixfmt
    taplo # TOML formatter and LSP
    zig
  ];
in
{

  # This is the neovim derivation returned by the overlay
  nvim-pkg = mkNeovim {
    plugins = my-plugins;
    inherit extraPackages;
    ignoreConfigRegexes = [
      "^plugin/neogit.lua"
      "^plugin/statuscol.lua"
    ];
  };

  nvim-dev = mkNeovim {
    plugins = my-plugins;
    inherit extraPackages;
    appName = "nvim-dev";
    wrapRc = false;
  };

  # This can be symlinked in the devShell's shellHook
  nvim-luarc-json = final.mk-luarc-json {
    plugins = my-plugins;
  };

  # You can add as many derivations as you like.
  # Use `ignoreConfigRegexes` to filter out config
  # files you would not like to include.
  #
  # For example:
  #
  # nvim-pkg-no-telescope = mkNeovim {
  #   plugins = [];
  #   ignoreConfigRegexes = [
  #     "^plugin/telescope.lua"
  #     "^ftplugin/.*.lua"
  #   ];
  #   inherit extraPackages;
  # };
}
