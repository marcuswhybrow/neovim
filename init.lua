
-- [[Editing]]

vim.g.mapleader = " "

-- File browser
vim.keymap.set("n", "<Leader>e", vim.cmd.Ex, { desc = '[E]xplore files in current directory' })

-- Move visual blocks up and down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = 'Move visual block down one line' })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = 'Move visual block up one line' })

-- Conflate lines
vim.keymap.set("n", "J", "mzJ`z", { desc = '[J]oin this line with the next line' })
-- Page up/down also centers screen 
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = 'Go [D]own and center the screen' })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = 'Go [U]p and center the screen' })
-- Next/prev search also centers screen
vim.keymap.set("n", "n", "nzzzv", { desc = 'Goto [N]ext search result and center the screen' })
vim.keymap.set("n", "N", "Nzzzv", { desc = 'Goto previous search result and center the screen' })

-- Paste over selection
vim.keymap.set("x", "<leader>p", "\"_dP", { desc = '[P]aste over selection' })

-- Yank to system clipboard
vim.keymap.set("n", "<leader>y", "\"+y", { desc = '[Y]ank to system clipboard' })
vim.keymap.set("v", "<leader>y", "\"+y", { desc = '[Y]ank to system clipboard' })
vim.keymap.set("n", "<leader>Y", "\"+Y", { desc = '[Y]ank to system clipboard' })

-- Delete to void register
vim.keymap.set("n", "<leader>d", "\"_d", { desc = '[D]elete to void register' })
vim.keymap.set("v", "<leader>d", "\"_d", { desc = '[D]elete to void register' })

-- Unmap Q
vim.keymap.set("n", "Q", "<nop>", { desc = 'Disable [Q] as it\'s too dangerous' })

--vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")

-- https://neovim.io/doc/user/quickfix.html
--vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
--vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
--vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
--vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Scripting
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = 'Enable e[X]ecute bit on current file' })

-- [[Settings]]

vim.api.nvim_command('set cmdheight=1')
vim.api.nvim_command('set number')

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = true

-- Long term undos
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@") -- no idea

vim.opt.updatetime = 50

-- [[lsp-zero]]

local lsp = require('lsp-zero').preset({
  -- https://github.com/VonHeikemen/lsp-zero.nvim/blob/v2.x/doc/md/api-reference.md#manage_nvim_cmp
  manage_nvim_cmp = {
    set_sources = "recommended",
    set_basic_mappings = true,
    set_extra_mappins = false, 
    use_luasnip = false,
    set_format = true,
    documentation_window = true,
  }
})

lsp.on_attach(function(client, bufnr)
  lsp.default_keymaps({ buffer = bufnr })
  lsp.buffer_autoformat()
  vim.keymap.set("n", "<leader>gr", "<cmd>Telescope lsp_references<cr>", { buffer = true })
end)

-- [[nvim-lspconfig]]

local lspconfig = require('lspconfig')

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
lspconfig.gopls.setup{}

-- https://templ.guide/commands-and-tools/ide-support#neovim--050
lspconfig.templ.setup{}

lspconfig.tailwindcss.setup({
  filetypes = {
    'templ',
    'html',
    'gohtml',
    'go',
  },
  init_options = {
    userLanguages = {
      templ = "html",
      go = "html",
    }
  },
  handlers = {
    -- https://github.com/tailwindlabs/tailwindcss-intellisense/issues/188#issuecomment-886110433
    ["tailwindcss/getConfiguration"] = function (_, _, params, _, bufnr, _)
      -- tailwindcss lang server waits for this repsonse before providing hover
      vim.lsp.buf_notify(bufnr, "tailwindcss/getConfigurationResponse", { _id = params._id })
    end
  },
})

lspconfig.nil_ls.setup{}
lspconfig.bashls.setup{}
lspconfig.html.setup({
  filetypes = { "html" }, -- Omits implicit "templ" to prevent formatting bug
})
lspconfig.cssls.setup{}
lspconfig.jsonls.setup{}
lspconfig.eslint.setup{}
lspconfig.yamlls.setup{}
lspconfig.marksman.setup{}

-- Perform Typescript checking on JavaScript
-- https://www.reddit.com/r/neovim/comments/132ax85/comment/jiacvuy/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
lspconfig.tsserver.setup{
  settings = {
    implicitProjectConfiguration = {
      target = "ES2021",
      checkJs = true
    }
  }
}

lspconfig.rust_analyzer.setup{
  settings = {
    ['rust-analyzer'] = {
      diagnostics = {
        enable = true;
        disabled = {"unresolved-proc-macro"},
        enableExperimental = true,
      },

      cargo = {
        buildScripts = {
          enable = true;
        },
      },

      procMacro = {
        enable = true;
      },
    },
  },
}

-- Manual formatting (instead of buffer_autoformat() above)
--[[
lsp.format_on_save({
servers = {
["lua_ls"] = {"lua"},
}
})
--]]

lsp.set_sign_icons({
  error = '✘',
  warn = '▲',
  hint = '⚑',
  info = '»',
})

lsp.setup()

vim.keymap.set("n", "lr", ":LspRestart<cr>", { desc = "[L]SP [R]estart" })

-- [[catppuccin-nvim]]

require("catppuccin").setup({
  flavour = "latte",
  background = {
    light = "latte",
    dark = "mocha",
  },
  transparent_background = false; -- use different plugin
})
vim.cmd.colorscheme "catppuccin"

vim.api.nvim_set_hl(0, "ColorColumn", { ctermbg=0, bg="#f0f0f0" })
vim.opt.colorcolumn = "80"

-- [[gitsigns-nvim]]

require('gitsigns').setup()

-- [[harpoon]]

local harpoon_mark = require("harpoon.mark")
local harpoon_ui = require("harpoon.ui")
vim.keymap.set("n", "<leader>a", harpoon_mark.add_file, { desc = '[A]dd file to Harpoon' })
vim.keymap.set("n", "<C-e>", harpoon_ui.toggle_quick_menu, { desc = '[E]nter Harpoon' }) 
vim.keymap.set("n", "<C-h>", function() harpoon_ui.nav_file(1) end, { desc = 'Open first path in Harpoon' }) 
vim.keymap.set("n", "<C-j>", function() harpoon_ui.nav_file(2) end, { desc = 'Open seond path in Harpoon' }) 
vim.keymap.set("n", "<C-k>", function() harpoon_ui.nav_file(3) end, { desc = 'Open third path in Harpoon' }) 
vim.keymap.set("n", "<C-l>", function() harpoon_ui.nav_file(4) end, { desc = 'Open forth path in Harpoon' }) 

-- [[lualine]]

-- https://neovim.io/doc/user/options.html#'showtabline'
vim.api.nvim_set_option('showtabline', 0)
vim.api.nvim_command(':hi! link StatusLine lualine_z_inactive')
vim.api.nvim_command(':hi! link StatusLineNC lualine_z_inactive')
vim.api.nvim_command(':hi! link SignColumn Normal')

-- toggle status line
vim.keymap.set('n', '<Leader>s', function()
  if vim.api.nvim_get_option('laststatus') == 0 then
    vim.api.nvim_set_option('laststatus', 2)
  else
    vim.api.nvim_set_option('laststatus', 0)
  end
end, { desc = '[S]how status line' })

local filename = {
  'filename',
  file_status = true,
  newfile_status = true,
  path = 1,
  shorting_target = 40,
  symbols = {
    modified = '[+]',
    readonly = '[-]',
    unnamed = '[No Name]',
    newfile = '[New]',
  },
  padding = { left = 1, right = 0 },
}

local filetype = {
  'filetype',
  colored = false,
  icon_only = true,
  padding = { left = 1, right = 1 },
}

local diff = {
  'diff',
  colored = false,
  diff_color = {
    added    = 'DiffAdd',
    modified = 'DiffChange',
    removed  = 'DiffDelete',
  },
  symbols = {
    added = '+',
    modified = '~',
    removed = '-'
  },
}

local branch = {
  'branch',
  icon = { '', align='right' },
  padding = { left = 1, right = 0 },
}

local diagnostics = {
  sources = { 'nvim_lsp', 'nvim_diagnostic' },
  sections = { 'error', 'warn', 'info', 'hint' },

  diagnostics_color = {
    error = 'DiagnosticError',
    warn  = 'DiagnosticWarn',
    info  = 'DiagnosticInfo',
    hint  = 'DiagnosticHint',
  },
  symbols = {
    error = 'E',
    warn = 'W',
    info = 'I',
    hint = 'H'
  },
  colored = true,
  update_in_insert = false,
  always_visible = true,
}

local location = {
  'location',
  padding = { left = 0, right = 1 },
}

local progress = {
  'progress',
  padding = { left = 1, right = 0 },
}

local active = { bg = '#eaeaed', fg = '#000000' }
local inactive = { bg = '#eeeeee', fg = '#000000' }
local insert = { fg = '#000000', bg = '#80a0ff' }
local visual = { fg = '#000000', bg = '#79dac8' }
local replace = { fg = '#000000', bg = '#ff5189' }
local command = { fg = '#000000', bg = '#d183e8' }

vim.api.nvim_set_hl(0, "StatusLine", { bg = '#dddddd' })
vim.api.nvim_command('hi SignColumn ctermbg=none')

local allParts = function(s)
  return { a = s, b = s, c = s, x = s, y = s, z = s }
end

require('lualine').setup({
  options = {
    globalstatus = false,
    component_separators = '',
    -- section_separators = '',
    section_separators = { left = '', right = '' },
    always_divide_middle = true,
    
    theme = "catppuccin",

    -- theme = {
    --   normal = {
    --     a = active,
    --     b = active,
    --     c = active,
    --     x = active,
    --     y = active,
    --     z = active,
    --   },

    --   insert = allParts(insert),
    --   visual = allParts(visual),
    --   replace = allParts(replace),

    --   inactive = {
    --     a = inactive,
    --     b = inactive,
    --     c = inactive,
    --     x = inactive,
    --     y = inactive,
    --     z = inactive,
    --   },
    -- },
  },

  sections = {
    lualine_a = {
      filename,
    },
    lualine_b = {
      filetype,
      branch,
      diff,
    },
    lualine_c = {
      diagnostics,
    },
    lualine_x = {},
    lualine_y = {
      progress,
      location,
    },
    lualine_z = {
      'mode',
    },
  },

  inactive_sections = {
    lualine_a = { filename },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
  },

  extensions = {},
})

-- [[nvim-cmp]]

local cmp = require('cmp')
local cmp_action = require('lsp-zero').cmp_action()

cmp.setup({
  preselect = "item",

  completion = {
    completeopt = "menu,menuone,noinsert",
  },

  mapping = {
    ["<Tab>"] = cmp_action.tab_complete(),
    ["<S-Tab>"] = cmp_action.select_prev_or_fallback(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  },

  snippet = {
    expand = function(args)
      local luasnip = require("luasnip")
      if not luasnip then
        return
      end 
      luasnip.lsp_expand(args.body)
    end,
  },

  sources = {
    { name = "path" },
    { name = "nvim_lsp" },
    { name = "buffer" },
    { name = "nvim_lua" },
  },
})

cmp.setup.filetype("gitcommit", {
  source = cmp.config.sources({
    { name = "cmp_git" },
  }, {
    { name = "buffer" },
  })
})

cmp.setup.cmdline({ "/", "?" }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = "buffer" },
  },
})

cmp.setup.cmdline(":", {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = "path" },
  }, {
    { name = "cmdline" },
  })
})

-- [[nvim-treesitter]] 

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = "gnn",
      scope_incremental = "grc",
      node_incremental = "grn",
      node_decremental = "grm",
    },
  },
  indent = {
    enable = true,
  },
}

vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.foldenable = false

-- [[telescope-nvim]]

local telescopeBuiltin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', telescopeBuiltin.find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fg', telescopeBuiltin.live_grep, { desc = '[F]ind using [G]rep' })
vim.keymap.set('n', '<leader>fb', telescopeBuiltin.buffers, { desc = '[F]ind within all [B]uffers' })
vim.keymap.set('n', '<leader>fh', telescopeBuiltin.help_tags, { desc = '[F]ind within [H]elp tags' })
vim.keymap.set('n', '<leader>fk', telescopeBuiltin.keymaps, { desc = '[F]ind [K]eymaps' })

vim.keymap.set('n', '<leader>ba>', 'ysiw]ysiw]', { desc = 'Surround inner word with double brackets' })
vim.keymap.set('n', '<leader>bd', 'ds]ds]', { desc = 'Delete inner word\'s double brackets' })

-- [[templ-vim]]

vim.api.nvim_create_autocmd(
  { "BufWritePre" },
  {
    pattern = { "*.templ" },
    callback = vim.lsp.buf.format
  }
)

-- [[trouble-nvim]]

vim.keymap.set("n", "<leader>xx", function() require("trouble").toggle() end, { desc = "Toggle Trouble. 🚦 A pretty diagnostics, references, telescope results, quickfix and location list to help you solve all the trouble your code is causing. " })
vim.keymap.set("n", "<leader>xd", function() require("trouble").toggle("diagnostics") end, { desc = "Toggle diagnostics from the builtin LSP client, in Trouble" })
vim.keymap.set("n", "<leader>xq", function() require("trouble").toggle("quickfix") end, { desc = "Toggle quickfix items, in Trouble" })
vim.keymap.set("n", "<leader>xl", function() require("trouble").toggle("loclist") end, { desc = "Toggle items from the window's location list, in Trouble" })
vim.keymap.set("n", "gR", function() require("trouble").toggle("lsp_references") end, { desc = "Toggle references of the word under the cursor from the builtin LSP client, in Trouble" })

-- [[undotree]]

vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = 'Open [U]ndo tree' })

-- [[vim-fugitive]]

vim.keymap.set("n", "<leader>gs", ":Git<cr>", { desc = '[G]it [S]how' })
vim.keymap.set("n", "<leader>gp", ":Git push<cr>", { desc = '[G]it [P]ush' })
