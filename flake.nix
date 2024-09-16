{
  description = "Neovim editor, configured by Marcus";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    harpoon.url = "github:NixOS/nixpkgs/8cfef6986adfb599ba379ae53c9f5631ecd2fd9c";
  };

  outputs = inputs: let 
    pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;

    config = pkgs.neovimUtils.makeNeovimConfig {
      withPython3 = false; 
      extraPython3Packages = _: [ ];
      withNodeJs = false;
      withRuby = false;
      extraLuaPackages = _: [];
      customRC = "";
      extraName = "";
      withPython2 = false;
      vimAlias = false; 
      viAlias = false;
      wrapRc = false;
      neovimRcContent = "";
      plugins = [
        pkgs.vimPlugins.telescope-nvim
        pkgs.vimPlugins.telescope-fzf-native-nvim
        pkgs.vimPlugins.nvim-web-devicons
        pkgs.vimPlugins.undotree
        pkgs.vimPlugins.trouble-nvim
        pkgs.vimPlugins.vim-nix
        pkgs.vimPlugins.luasnip
        pkgs.vimPlugins.nvim-lspconfig
        pkgs.vimPlugins.nvim-cmp
        pkgs.vimPlugins.cmp_luasnip
        pkgs.vimPlugins.cmp-nvim-lsp
        pkgs.vimPlugins.cmp-nvim-lua
        pkgs.vimPlugins.cmp-buffer
        pkgs.vimPlugins.cmp-path
        pkgs.vimPlugins.cmp-cmdline
        pkgs.vimPlugins.cmp-cmdline-history
        pkgs.vimPlugins.cmp-git
        pkgs.vimPlugins.vim-commentary
        pkgs.vimPlugins.vim-surround
        pkgs.vimPlugins.vim-fugitive
        pkgs.vimPlugins.gitsigns-nvim
        pkgs.vimPlugins.lualine-nvim
        pkgs.vimPlugins.catppuccin-nvim
        pkgs.vimPlugins.plenary-nvim
        pkgs.vimPlugins.vim-startuptime
        pkgs.vimPlugins.nvim-highlight-colors 

        inputs.harpoon.legacyPackages.x86_64-linux.vimPlugins.harpoon

        # nvim-treesitter
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
        ]))

        # templ-vim
        (pkgs.vimUtils.buildVimPlugin {
          pname = "templ-vim";
          version = "5cc48b93a4538adca0003c4bc27af844bb16ba24";
          src = pkgs.fetchFromGitHub {
            owner = "joerdav";
            repo = "templ.vim";
            rev = "5cc48b93a4538adca0003c4bc27af844bb16ba24";
            sha256 = "sha256-YdV8ioQJ10/HEtKQy1lHB4Tg9GNKkB0ME8CV/+hlgYs=";
          };
        })

        # vim-eel2
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

        # lsp-zero-nvim
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

        # bg-nvim
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
      ];
    };

    neovim = pkgs.wrapNeovimUnstable pkgs.neovim-unwrapped config;

    inPath = pkgs.lib.makeBinPath (with pkgs; [
      nil # nix
      gopls # golang
      nodePackages."@tailwindcss/language-server" # tailwind CSS processor
      nodePackages.bash-language-server # BASH
      nodePackages.vscode-langservers-extracted # html css json eslint
      nodePackages.yaml-language-server # yaml
      rust-analyzer #rust
      marksman # markdown
      typescript-language-server # typescript jsdoc
    ]);

    initFile = pkgs.writeText "neovim-init.lua" (builtins.readFile ./init.lua);

    init = pkgs.runCommand "neovim-init.lua" {} ''
      mkdir --parents $out/share/nvim
      ln --symbolic ${initFile} $out/share/nvim/init.lua
    '';

    wrapper = pkgs.runCommand "neovim-wrapper" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      makeWrapper ${neovim}/bin/nvim $out/bin/nvim \
        --add-flags "-u ${init}/share/nvim/init.lua" \
        --suffix PATH : ${inPath}
      ln --symbolic $out/bin/nvim  $out/bin/vim
      '';

    wrapper-no-lsp = pkgs.runCommand "neovim-wrapper-no-lsp" {
      nativeBuildInputs = [ pkgs.makeWrapper ];
    } ''
      makeWrapper ${neovim}/bin/nvim $out/bin/nvim \
        --add-flags "-u ${init}/share/nvim/init.lua" \
        --suffix PATH : ${inPath}
      ln --symbolic $out/bin/nvim $out/bin/vim
    '';

    fishAbbrs = pkgs.writeTextDir "share/fish/vendor_conf.d/marcuswhybrow-neovim.fish" ''
      if status is-interactive
        abbr --add t vim ~/obsidian/Timeline/$(date +%Y-%m-%d).md
        abbr --add y vim ~/obsidian/Timeline/$(date +%Y-%m-%d --date yesterday).md
      end
    '';
  in {
    packages.x86_64-linux.nvim = pkgs.symlinkJoin {
      name = "nvim";
      paths = [ 
        wrapper 
        init 
        pkgs.neovim 
        fishAbbrs 
      ];
      meta.description = "Neovim including LSP config and servers";
    };

    packages.x86_64-linux.nvim-no-lsp = pkgs.symlinkJoin {
      name = "nvim";
      paths = [ 
        wrapper-no-lsp 
        init 
        pkgs.neovim 
        fishAbbrs
      ];
      meta.description = "Neovim with LSP configured but without LSP *servers*";
    };

    packages.x86_64-linux.default = inputs.self.packages.x86_64-linux.nvim;

    apps.x86_64-linux.neovim = {
      type = "app";
      program = "${inputs.self.packages.x86_64-linux.nvim}/bin/nvim";
    };
  };
}
