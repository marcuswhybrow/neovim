{
  description = "Neovim editor, configured by Marcus";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs: let 
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

    # For all args available for makeNeovimConfig see 
    # https://github.com/NixOS/nixpkgs/blob/9b79a05ae1311685f77dafbdfc88e81e390b22f1/pkgs/applications/editors/neovim/utils.nix#L26
    neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped (pkgs.neovimUtils.makeNeovimConfig {
      withPython3 = false; 
      withRuby = false;

      extraLuaPackages = luaPackages: [
        # pkgs.vimPlugins.telescope-nvim
        luaPackages.telescope-nvim
      ];

      plugins = [
        # USER INTERFACE

        # Custom status line configuration (very important)
        # pkgs.vimPlugins.lualine-nvim # Not new enough
        (pkgs.vimUtils.buildVimPlugin {
          pname = "lualine-nvim";
          version = "2025-03-27";
          src = pkgs.fetchFromGitHub {
            owner = "nvim-lualine";
            repo = "lualine.nvim";
            rev = "1517caa8fff05e4b4999857319d3b0609a7f57fa";
            sha256 = "sha256-DAYRf8JIty6W78JXBSyfnyCryUUYX+QrsHSAlcOk7Fc=";
          };
        })

        # LSP & Message viewer
        pkgs.vimPlugins.fidget-nvim

        # Color theme
        pkgs.vimPlugins.catppuccin-nvim

        # Auto detect terminal light/dark theme
        (pkgs.vimUtils.buildVimPlugin {
          pname = "auto-dark-mode";
          version = "2025-03-10";
          src = pkgs.fetchFromGitHub {
            owner = "f-person";
            repo = "auto-dark-mode.nvim";
            rev = "c31de126963ffe9403901b4b0990dde0e6999cc6";
            sha256 = "sha256-ZCViqnA+VoEOG+Xr+aJNlfRKCjxJm5y78HRXax3o8UY=";
          };
        })

        # Makes the background of CSS colors the actual color defined
        pkgs.vimPlugins.nvim-highlight-colors 

        # Interactively shows possible key bindngs
        pkgs.vimPlugins.which-key-nvim

        # NAVIGATION

        # Manage the file system and other tree like structures
        pkgs.vimPlugins.neo-tree-nvim

        # Popup project search box with file preview
        pkgs.vimPlugins.telescope-nvim

        # Fuzzy search for telescope
        pkgs.vimPlugins.telescope-fzf-native-nvim

        # Telescope file icons
        pkgs.vimPlugins.nvim-web-devicons

        # Sidebar that can save your ass when you've overriden undos
        pkgs.vimPlugins.undotree

        # Pin specific files to specific keys for instanst switching
        pkgs.vimPlugins.harpoon

        # Navigate vim and tmux splits with the same keymaps
        pkgs.vimPlugins.vim-tmux-navigator

        # SYNTAX HIGHLIGHTING

        # Treesitter parses files into trees of tokens for cheap syntax 
        # highlighting and easy code folding. 
        (pkgs.vimPlugins.nvim-treesitter.withPlugins (treesitter: [
          treesitter.nix 
          treesitter.go 
          treesitter.rust 
          treesitter.bash 
          treesitter.fish 
          treesitter.html 
          treesitter.css 
          treesitter.json 
          treesitter.yaml 
          treesitter.toml 
          treesitter.ron 
          treesitter.lua
          treesitter.c 
          treesitter.templ 
          treesitter.javascript
          treesitter.hyprlang
        ]))

        # LANGUAGE SERVER PROTOCOL

        # Lists project-wide LSP errors for you to fix
        pkgs.vimPlugins.trouble-nvim

        # Better (multiline) inline LSP diagnostics 
        (pkgs.vimUtils.buildVimPlugin {
          pname = "tiny-inline-diagnostic";
          version = "2025-03-11";
          src = pkgs.fetchFromGitHub {
            owner = "rachartier";
            repo = "tiny-inline-diagnostic.nvim";
            rev = "5d168a2826fb90691f674e81bd5c1dfa6d931c61";
            sha256 = "sha256-WWT/RGP4+OB6CvEKvGed+aD0Yf30AQvnOcOKZ/gjggk=";
          };
        })

        # Preview and exectue LSP code actions
        (pkgs.vimUtils.buildVimPlugin {
          pname = "tiny-code-action";
          version = "2019-11-16";
          doCheck = false; # Error's looking for `require("telescope")`
          src = pkgs.fetchFromGitHub {
            owner = "rachartier";
            repo = "tiny-code-action.nvim";
            rev = "cc2f6045e67e01355c49fea10568baba856e844a";
            sha256 = "sha256-JBGP8alg8REwBsfKPpDoxPDQtImvh1etyhK9U/YA1c4=";
          };
        })

        # COMPLETION

        # Code completion popup
        pkgs.vimPlugins.nvim-cmp

        # Code completion of common code patterns
        pkgs.vimPlugins.luasnip
        pkgs.vimPlugins.cmp_luasnip

        # Language Server Protocol configurations & completion
        pkgs.vimPlugins.cmp-nvim-lsp

        # Completion for Neovim Lua API
        pkgs.vimPlugins.cmp-nvim-lua

        # Completion from word extant in the current buffer (file being edited)
        pkgs.vimPlugins.cmp-buffer

        # Completion from working directory paths
        pkgs.vimPlugins.cmp-path

        # Completion inside the Neovim command line too
        pkgs.vimPlugins.cmp-cmdline

        # Complete Neovim command line from it's own history
        pkgs.vimPlugins.cmp-cmdline-history

        # Complete from Git refs and such (I think)
        pkgs.vimPlugins.cmp-git

        # EDITING

        # Easily comment out blocks of code
        pkgs.vimPlugins.vim-commentary

        # Parenthesis, string quotes, HTML tag wrapping, all that stuff
        pkgs.vimPlugins.vim-surround

        # SOURCE CONTROL

        # Git commits (and more) inside of Neovim
        pkgs.vimPlugins.vim-fugitive

        # Color git additions and deletions for each buffer
        pkgs.vimPlugins.gitsigns-nvim

        # LANGUAGE SPECIFIC

        # Syntax highlighting for Nix (However the Nix LSP may supersede this)
        pkgs.vimPlugins.vim-nix

        # Golang's Templ templating language
        pkgs.vimPlugins.templ-vim

        # REAPER's (DAW) JSFX plugin language
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

        # UTILS

        # A utils library for other plugins (not sure which)
        pkgs.vimPlugins.plenary-nvim

        # Measure's Neovim's startup time for debugging any issues there
        pkgs.vimPlugins.vim-startuptime
      ];
    });

  in {
    packages.x86_64-linux.nvim = pkgs.symlinkJoin {
      name = "nvim";
      meta.description = "Neovim including LSP config and servers";
      paths = [ 
        (pkgs.runCommand "neovim-wrapper" {
          nativeBuildInputs = [ pkgs.makeWrapper ];
        } ''
          mkdir --parents $out/share/nvim
          ln --symbolic \
          ${pkgs.writeText "neovim-init.lua" (builtins.readFile ./init.lua)} \
          $out/share/nvim/init.lua

          makeWrapper ${neovim}/bin/nvim $out/bin/nvim \
            --add-flags "-u $out/share/nvim/init.lua" \
            --suffix PATH : ${pkgs.lib.makeBinPath [
              # Nix LSP server
              pkgs.nil

              # Tailwind LSP server
              pkgs.nodePackages."@tailwindcss/language-server"

              # BASH LSP server
              pkgs.nodePackages.bash-language-server

              # HTML, CSS, JSON & Eslint LSP servers
              pkgs.nodePackages.vscode-langservers-extracted

              # YAML LSP server
              pkgs.nodePackages.yaml-language-server

              # Markdown LSP server
              pkgs.marksman

              # Required by pkgs.vimPlugins.cmp-git
              pkgs.curl

              # Required by the file content's search of pkgs.vimPlugins.telescope-nvim
              pkgs.ripgrep

              # Required by the fuzzy finder search for pkgs.vimPlugins.telescope-nvim
              pkgs.fzf

              # Required by tiny-code-action for code action previews
              pkgs.delta
            ]}

          # Alias vim to nvim
          ln --symbolic $out/bin/nvim  $out/bin/vim
        '')

        # The original Neovim package
        pkgs.neovim 
      ];
    };

    packages.x86_64-linux.default = inputs.self.packages.x86_64-linux.nvim;

    apps.x86_64-linux.neovim = {
      type = "app";
      program = "${inputs.self.packages.x86_64-linux.nvim}/bin/nvim";
    };
  };
}
