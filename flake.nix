{
  description = "Neovim editor, configured by Marcus";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: let 
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    xdgConfig = pkgs.stdenv.mkDerivation {
      name = "neovim-config";
      src = ./lua;
      installPhase = ''
        mkdir --parents $out/nvim/lua
        cp --recursive userconfig $out/nvim/lua
        echo 'require("userconfig")' > $out/nvim/init.lua
      '';
    };  
    config = pkgs.neovimUtils.makeNeovimConfig {
      # https://github.com/NixOS/nixpkgs/blob/db24d86dd8a4769c50d6b7295e81aa280cd93f35/pkgs/applications/editors/neovim/utils.nix#L24
      withPython3 = false; # defaults to true
      extraPython3Packages = _: [ ];
      withNodeJs = false;
      withRuby = false; # defaults to true
      extraLuaPackages = _: [];
      customRC = '''';

      # Search search.nixos.org for "vimPlugins". Can't find a plugin? Wrap it's
      # GitHub repo with `pkgs.vimutils.buildVimPlugins` for the same result
      plugins = with pkgs.vimPlugins; [

        # FILE SEARCH & MORE

        # https://github.com/nvim-telescope/telescope.nvim
        # Find, Filter, Preview, Pick. All lua, all the time.
        # (Fast syntax highlighting)
        telescope-nvim

        # https://github.com/nvim-telescope/telescope-fzf-native.nvim
        # FZF sorter for telescope written in c
        telescope-fzf-native-nvim

        # https://github.com/nvim-tree/nvim-web-devicons
        # lua `fork` of vim-web-devicons for neovim
        # 
        # (Adds file type icons to Vim plugins such as: NERDTree, vim-airline, 
        # CtrlP, unite, Denite, lightline, vim-startify and many more)
        nvim-web-devicons

        # https://github.com/ThePrimeagen/harpoon
        # Getting you where you want with the fewest keystrokes.
        harpoon

        # https://github.com/mbbill/undotree
        # The undo history visualizer for VIM
        undotree



        # LANGUAGE FEATURES

        # https://github.com/nvim-treesitter/nvim-treesitter
        # Nvim Treesitter configurations and abstraction layer
        (nvim-treesitter.withPlugins (p: with p; [
          nix
          go
          rust
          bash fish
          html css
          json yaml toml ron
          lua
          c

          # Golang templ (template language)
          (pkgs.vimUtils.buildVimPlugin {
            pname = "tree-sitter-templ";
            version = "89e5957b47707b16be1832a2753367b91fb85be0";
            src = pkgs.fetchFromGitHub {
              owner = "vrischmann";
              repo = "tree-sitter-templ";
              rev = "89e5957b47707b16be1832a2753367b91fb85be0";
              sha256 = "sha256-nNC0mMsn5KAheFqOQNbbcXYnyd2S8EoGc1k+1Zi6PVc=";
            };
          })
        ]))

        # 🚦A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing. 
        # https://github.com/folke/trouble.nvim/
        trouble-nvim

        # https://github.com/LnL7/vim-nix
        # Vim configuration files for Nix
        vim-nix # Not sure I need this if treesitter has a nix plugin?

        (pkgs.vimUtils.buildVimPlugin {
          pname = "templ.vim";
          version = "5cc48b93a4538adca0003c4bc27af844bb16ba24";
          src = pkgs.fetchFromGitHub {
            owner = "joerdav";
            repo = "templ.vim";
            rev = "5cc48b93a4538adca0003c4bc27af844bb16ba24";
            sha256 = "sha256-YdV8ioQJ10/HEtKQy1lHB4Tg9GNKkB0ME8CV/+hlgYs=";
          };
        })

        # REAPER JSFX/EEL2 syntax highlighting
        (pkgs.vimUtils.buildVimPlugin {
          pname = "vim-eel2";
          version = "2019-11-16";
          src = pkgs.fetchFromGitHub {
            owner = "TristanCrawford";
            repo = "vim-eel2";
            rev = "6865d0f3e92bb5feb0108cc20f89f69659021483";
            sha256 = "sha256-lAekmwJxXN+Y6zIxcaJTAftA7919J4Vl1SRjdhx2X8M=";
          };
        })


        # AUTOCOMPLETE

        # https://github.com/l3mon4d3/luasnip/
        # Snippet Engine for Neovim written in Lua
        luasnip

        # https://github.com/neovim/nvim-lspconfig
        # Quickstart configs for Nvim LSP
        nvim-lspconfig

        # https://github.com/VonHeikemen/lsp-zero.nvim
        # A starting point to setup some lsp related features in neovim.
        (pkgs.vimUtils.buildVimPlugin {
          pname = "lsp-zero-nvim";
          version = "2.x";
          src = pkgs.fetchFromGitHub {
            owner = "VonHeikemen";
            repo = "lsp-zero.nvim";
            rev = "eb278c30b6c50e99fdfde52f7da0e0ff8d17c07e";
            sha256 = "sha256-C2LvhoNdNXRyG+COqVZv/BcUh6y82tajXipsqdySJJQ=";
          };
        })

        # https://github.com/hrsh7th/nvim-cmp
        # A completion plugin for neovim coded in Lua.
        nvim-cmp

        # https://github.com/saadparwaiz1/cmp_luasnip
        # luasnip completion source for nvim-cmp
        cmp_luasnip

        # https://github.com/hrsh7th/cmp-nvim-lsp
        # nvim-cmp source for neovim builtin LSP client
        cmp-nvim-lsp

        # https://github.com/hrsh7th/cmp-nvim-lua
        # nvim-cmp source for nvim lua
        cmp-nvim-lua

        # https://github.com/hrsh7th/cmp-buffer
        # nvim-cmp source for buffer words
        cmp-buffer

        # https://github.com/hrsh7th/cmp-path
        # nvim-cmp source for path
        cmp-path

        # https://github.com/hrsh7th/cmp-cmdline
        # nvim-cmp source for vim's cmdline
        cmp-cmdline

        # https://github.com/dmitmel/cmp-cmdline-history
        # Source for nvim-cmp which reads results from command-line or search 
        # histories
        cmp-cmdline-history

        # https://github.com/petertriho/cmp-git
        # Git source for nvim-cmp
        cmp-git


        # QUALITY OF LIFE

        # https://github.com/tpope/vim-commentary
        # comment stuff out
        vim-commentary

        # https://github.com/tpope/vim-surround
        # Delete/change/add parentheses/quotes/XML-tags/much more with ease
        vim-surround


        # VERSION CONTROL

        # https://github.com/tpope/vim-fugitive
        # A Git wrapper so awesome, it should be illegal
        vim-fugitive


        # https://github.com/lewis6991/gitsigns.nvim
        # Git integration for buffers
        gitsigns-nvim


        # INTERFACE CUSOMISATION

        # https://github.com/nvim-lualine/lualine.nvim
        # A blazing fast and easy to configure neovim statusline plugin written 
        # in pure lua.
        lualine-nvim

        # https://github.com/catppuccin/nvim/
        # 🍨 Soothing pastel theme for (Neo)vim 
        catppuccin-nvim

        # https://github.com/projekt0n/github-nvim-theme
        # Github's Neovim themes
        # (A nice light (white) theme from which to start)
        (pkgs.vimUtils.buildVimPlugin rec {
          pname = "github-nvim-theme";
          version = "0.0.7";
          src = pkgs.fetchFromGitHub {
            owner = "projekt0n";
            repo = pname;
            rev = "v${version}";
            sha256 = "sha256-Qm9ffdkHfG5+PLQ8PbOeFMywBbKVGqX8886clQbJzyg=";
          };
        })

        (pkgs.vimUtils.buildVimPlugin {
          pname = "transparent-nvim";
          version = "3af6232c8d39d51062702e875ff6407c1eeb0391";
          src = pkgs.fetchFromGitHub {
            owner = "xiyaowong";
            repo = "transparent.nvim";
            rev = "3af6232c8d39d51062702e875ff6407c1eeb0391";
            sha256 = "sha256-1JyfwHBCtNCPmsOLzJRWBtg1u9uApQZY4fn2mTL3NZ4=";
          };
        })

        (pkgs.vimUtils.buildVimPlugin rec {
          pname = "bg-nvim";
          version = "1c95261cc5e3062e3b277fc5c15d180d51a40f62";
          src = pkgs.fetchFromGitHub {
            owner = "typicode";
            repo = "bg.nvim";
            rev = version; 
            sha256 = "sha256-ZocdEdw7m6gVQap0MFr1uymIkHnX9ewjWmR7fYVR9Ko=";
          };
        })

        # OTHER

        # https://github.com/nvim-lua/plenary.nvim
        # plenary: full; complete; entire; absolute; unqualified. All the lua 
        # functions I don't want to write twice.
        plenary-nvim

        # DIAGNOSTICS

        # https://github.com/dstein64/vim-startuptime
        # A plugin for profiling Vim and Neovim startup time. 
        vim-startuptime
      ];

      # https://github.com/NixOS/nixpkgs/blob/db24d86dd8a4769c50d6b7295e81aa280cd93f35/pkgs/applications/editors/neovim/wrapper.nix#L13
      extraName = "";
      withPython2 = false;
      vimAlias = true;
      viAlias = false;
      wrapRc = false;
      neovimRcContent = "";
    };
    neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped config;

    path = pkgs.lib.makeBinPath [
      pkgs.nil
      pkgs.gopls
      pkgs.nodePackages."@tailwindcss/language-server"
      pkgs.nodePackages.bash-language-server
      pkgs.nodePackages.vscode-langservers-extracted # html css json eslint
      pkgs.nodePackages.yaml-language-server
      pkgs.rust-analyzer
      pkgs.marksman # markdown
    ];
    wrapper = pkgs.runCommand "neovim-wrapper" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      makeWrapper ${neovim}/bin/nvim $out/bin/nvim \
        --set XDG_CONFIG_HOME ${xdgConfig} \
        --suffix PATH : ${path}

    '';
  in {
    packages.x86_64-linux.nvim = pkgs.symlinkJoin {
      name = "nvim";
      paths = [ wrapper pkgs.neovim ];
    };

    packages.x86_64-linux.default = inputs.self.packages.x86_64-linux.nvim;

    apps.x86_64-linux.neovim = {
      type = "app";
      program = "${inputs.self.packages.x86_64-linux.nvim}/bin/nvim";
    };
  };
}
