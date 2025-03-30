
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

vim.keymap.set("n", "<leader>td", ":set bg=dark<CR>", { desc = 'Set theme to [D]ark mode' })
vim.keymap.set("n", "<leader>tl", ":set bg=light<CR>", { desc = 'Set theme to [L]ight mode' })




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

-- [[lsp-status]]
-- Must occur before lspconfig setup

-- local lsp_status = require("lsp-status")
-- lsp_status.config({
--   show_filename = true,
-- })

-- lsp_status.register_progress()

-- [[nvim-lspconfig]]
-- Must occur after lsp-status setup

local lspconfig = require('lspconfig')

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#cssls
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
-- capabilities = vim.tbl_extend("keep", capabilities or {}, lsp_status.capabilities)

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
lspconfig.gopls.setup({
  -- on_attach = lsp_status.on_attach,
  -- capabilities
})

-- https://templ.guide/commands-and-tools/ide-support#neovim--050
lspconfig.templ.setup({
  -- on_attach = lsp_status.on_attach,
  -- capabilities
})

lspconfig.tailwindcss.setup({
  -- on_attach = lsp_status.on_attach,
  -- capabilities,
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

lspconfig.nil_ls.setup({
  -- on_attach = lsp_status.on_attach,
  -- capabilities
})
lspconfig.bashls.setup({
  -- on_attach = lsp_status.on_attach,
  -- capabilities
})
lspconfig.cssls.setup({
  -- capabilities = capabilities,
})
lspconfig.jsonls.setup({
  -- on_attach = lsp_status.on_attach,
  -- capabilities
})
lspconfig.eslint.setup({
  -- on_attach = lsp_status.on_attach,
  -- capabilities
})
lspconfig.yamlls.setup({
  -- on_attach = lsp_status.on_attach,
  -- capabilities
})
lspconfig.marksman.setup({
  -- on_attach = lsp_status.on_attach,
  -- capabilities
})
lspconfig.hyprls.setup({
  -- on_attach = lsp_status.on_attach,
  -- capabilities
})

lspconfig.html.setup({
  -- on_attach = lsp_status.on_attach,
  -- capabilities,
  filetypes = { "html" }, -- Omits implicit "templ" to prevent formatting bug
})

-- -- Perform Typescript checking on JavaScript
-- -- https://www.reddit.com/r/neovim/comments/132ax85/comment/jiacvuy/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
-- lspconfig.tsserver.setup({
--   on_attach = lsp_status.on_attach,
--   settings = {
--     implicitProjectConfiguration = {
--       target = "ES2021",
--       checkJs = true
--     }
--   },
--   capabilities
-- })
lspconfig.ts_ls.setup({
  -- on_attach = lsp_status.on_attach,
  compilerOptions = {
    target = "ES2021",
    checkJs = true
  },
  -- capabilities
})

lspconfig.rust_analyzer.setup({
  -- on_attach = lsp_status.on_attach,
  -- capabilities,
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
})


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
  background = {
    light = "latte",
    dark = "mocha",
  },
  transparent_background = false; -- use different plugin
  custom_highlights = function(colors)
    return {
      TelescopeBorder = { link = "Comment" },
      NeoTreeNormal = { bg = "NONE" },
      NeoTreeNormalNC = { bg = "NONE" },
      NeoTreeStatusLineNC = { bg = "NONE" },
      MsgArea = { link = "Comment" },
      ModeMsg = { link = "Comment" },
      StatusLine = { bg = "NONE" },
      StatusLineNC = { bg = "NONE" },
      WinSeparator = { fg = "bg" },
      ColorColumn = { ctermbg = "black" },
    }
  end
})
vim.cmd.colorscheme "catppuccin"

-- vim.opt.colorcolumn = "80"


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

local comment_color = 'Comment'
local default_color = { fg = 'default', bg = 'default' }

vim.api.nvim_command('hi SignColumn ctermbg=none')

local allParts = function(s)
  return { a = s, b = s, c = s, x = s, y = s, z = s }
end

local firstPart = function(a, b)
  return { a = a, b = b, c = b, x = b, y = b, z = b }
end

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
  padding = { left = 0, right = 0 },
}

require('lualine').setup({
  options = {
    globalstatus = false,
    component_separators = '',
    section_separators = '',
    -- section_separators = { left = '', right = '' },
    always_divide_middle = true,
    
    -- theme = "catppuccin",

    theme = {
      normal = allParts(comment_color),
      inactive = allParts(comment_color),
      insert = allParts(comment_color),
      visual = allParts(comment_color),
      replace = allParts(comment_color),
    },
  },

  -- sections = {},
  -- inactive_sections = {},

  sections = {
    lualine_a = {
      filename,
    },
    lualine_b = {
      { 'progress', padding = { left = 1, right = 1 } },
      { 'location', padding = { left = 0, right = 0 } },
      { 
        "lsp_status",
        padding = { left = 0, right = 1 },
        icon = '', -- f013
        symbols = {
          -- Standard unicode symbols to cycle through for LSP progress:
          spinner = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
          -- Standard unicode symbol for when LSP is done:
          done = '✓',
          -- Delimiter inserted between LSP names:
          separator = ' ',
        },
      },
      {
        'diagnostics',
        padding = { left = 0, right = 0 },

        -- Table of diagnostic sources, available sources are:
        --   'nvim_lsp', 'nvim_diagnostic', 'nvim_workspace_diagnostic', 'coc', 'ale', 'vim_lsp'.
        -- or a function that returns a table as such:
        --   { error=error_cnt, warn=warn_cnt, info=info_cnt, hint=hint_cnt }
        sources = { 'nvim_lsp', 'nvim_diagnostic' },

        -- Displays diagnostics for the defined severity types
        sections = { 'error', 'warn', 'info', 'hint' },

        diagnostics_color = {
          -- Same values as the general color option can be used here.
          error = 'Comment', -- Changes diagnostics' error color.
          warn  = 'Comment',  -- Changes diagnostics' warn color.
          info  = 'Comment',  -- Changes diagnostics' info color.
          hint  = 'Comment',  -- Changes diagnostics' hint color.
        },
        symbols = {error = 'e', warn = 'w', info = 'i', hint = 'h'},
        colored = true,           -- Displays diagnostics status in color if set to true.
        update_in_insert = false, -- Update diagnostics in insert mode.
        always_visible = false,   -- Show diagnostics even if there are none.
      },
      -- filetype,
      -- branch,
      -- diff,
    },
    lualine_c = {
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {},
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

  formatting = {
    format = function(entry, item)
      return require("nvim-highlight-colors").format(entry, item)
    end
  }
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

-- [[neo-tree-nvim]]

require('neo-tree').setup({
  filesystem = {
    -- Default behaviour when opening Neovim on a directory is to replace 
    -- the NetRW file browser with a neo-tree window to the left and a
    -- window to the right. This requires closing two windows to exit.
    -- 
    -- "open_current" opens one window with neo-tree: only one thing to close!
    hijack_netrw_behavior = "open_current",
  },
  window = {
    mappings = {
      ["A"]  = "git_add_all",
      ["gu"] = "git_unstage_file",
      ["ga"] = "git_add_file",
      ["gr"] = "git_revert_file",
      ["gc"] = "git_commit",
      ["gp"] = "git_push",
      ["gg"] = "git_commit_and_push",
      ["<C-b>"] = "close_window",
    }
  }
})

vim.keymap.set('n', '<C-b>', ':Neotree toggle<CR>', { desc = 'Toggle open NeoTree file [B]rowser' })


-- [[telescope-nvim]]

local telescopeBuiltin = require('telescope.builtin')

vim.keymap.set('n', '<leader>ff', telescopeBuiltin.find_files, { desc = '[F]ind [F]iles' })
vim.keymap.set('n', '<leader>fg', telescopeBuiltin.live_grep, { desc = '[F]ind using [G]rep' })
vim.keymap.set('n', '<leader>fb', telescopeBuiltin.buffers, { desc = '[F]ind within all [B]uffers' })
vim.keymap.set('n', '<leader>fh', telescopeBuiltin.help_tags, { desc = '[F]ind within [H]elp tags' })
vim.keymap.set('n', '<leader>fk', telescopeBuiltin.keymaps, { desc = '[F]ind [K]eymaps' })
vim.keymap.set('n', '<leader>fd', telescopeBuiltin.diagnostics, { desc = '[F]ind [D]iagnostics' })

vim.keymap.set('n', '<leader>ba>', 'ysiw]ysiw]', { desc = 'Surround inner word with double brackets' })
vim.keymap.set('n', '<leader>bd', 'ds]ds]', { desc = 'Delete inner word\'s double brackets' })

vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#ff0000" })
vim.api.nvim_set_hl(0, "FloatBorder", { fg = "#ff0000" })

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

-- [[nvim-highlight-colors]]

vim.opt.termguicolors = true
require("nvim-highlight-colors").setup()

-- [[rust-analyzer]]

-- Fix for https://github.com/neovim/neovim/issues/30985 whereby rust-analyzer
-- constantly lags user input with the message "server cancelled the request".
-- https://github.com/neovim/neovim/issues/30985#issuecomment-2447329525
for _, method in ipairs({ 'textDocument/diagnostic', 'workspace/diagnostic' }) do
    local default_diagnostic_handler = vim.lsp.handlers[method]
    vim.lsp.handlers[method] = function(err, result, context, config)
        if err ~= nil and err.code == -32802 then
            return
        end
        return default_diagnostic_handler(err, result, context, config)
    end
end

-- Window splitting, moving, and navigating
-- <C-h>/<C-l>/etc. must come last to override something implicit above

vim.keymap.set("n", "<leader>sh", ":vsplit<CR>", { desc = '[S]plit window to the left' })
vim.keymap.set("n", "<leader>sl", ":vsplit<CR><C-w>l", { desc = '[S]plit window to the right' })
vim.keymap.set("n", "<leader>sj", ":split<CR><C-w>j", { desc = '[S]plit Add window below' })
vim.keymap.set("n", "<leader>sk", ":split<CR>", { desc = '[S]plit window above' })

vim.keymap.set("n", "<leader>wh", "<C-w>H", { desc = 'Move [W]indow to the far left' })
vim.keymap.set("n", "<leader>wl", "<C-w>L", { desc = 'Move [W]indow to the far right' })
vim.keymap.set("n", "<leader>wj", "<C-w>J", { desc = 'Move [W]indow to the bottom' })
vim.keymap.set("n", "<leader>wk", "<C-W>K", { desc = 'Move [W]indow to the top' })

vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = 'Move cursor to the window to the left' })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = 'Move cursor to the window to the right' })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = 'Move cursor to the window below' })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = 'Move cursor to the window above' })

require("auto-dark-mode").setup({
  fallback = "light"
})

-- [[which-key]]

require("which-key").setup({
  delay = 0,
  spec = {
    { "<leader>g", group = "[G]it commands" },
    { "<leader>f", group = "[F]ind files/words/keymaps/etc." },
    { "<leader>t", group = "[T]heme change to [L]ight or [D]ark" },
    { "<leader>w", group = "Move [W]indows using [HJKL]" },
    { "<leader>c", group = "LSP [C]ode actions" },
  },
})

-- [[tiny-inline-diagnostic]]

vim.diagnostic.config({ 
  virtual_text = false,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = '',
      [vim.diagnostic.severity.WARN] = '',
      [vim.diagnostic.severity.INFO] = '',
      [vim.diagnostic.severity.HINT] = '',
    },
  },
  -- virtual_lines = {
  --   current_line = false,
  -- }
})

require("tiny-inline-diagnostic").setup({
  preset = "powerline", -- modern/classic/minimal/powerline/ghost/simple/nonerdfont/amongus
  options = {
    multilines = {
      enabled = true,
      always_show = true,
    },
    show_all_diags_on_cursorline = false,
    overflow = {
      mode = "wrap", -- wrap/none/oneline
    },
    break_line = {
      enabled = false,
      after = 30,
    },
  }
})

-- [[tiny-code-action]]

local tiny_code_action = require("tiny-code-action")
tiny_code_action.setup({
  backend = "delta", -- vim/delta/difftastic
})

vim.keymap.set("n", "<leader>ca", function()
  tiny_code_action.code_action()
end, { noremap = true, silent = true, desc = "Open LSP [C]ode [A]ctions" })

-- [[fidget--nvim]]

-- https://github.com/j-hui/fidget.nvim?tab=readme-ov-file#options
require("fidget").setup({
  -- Options related to LSP progress subsystem
  progress = {
    poll_rate = 0,                -- How and when to poll for progress messages
    suppress_on_insert = false,   -- Suppress new messages while in insert mode
    ignore_done_already = false,  -- Ignore new tasks that are already complete
    ignore_empty_message = false, -- Ignore new tasks that don't contain a message
    clear_on_detach =             -- Clear notification group when LSP server detaches
      function(client_id)
        local client = vim.lsp.get_client_by_id(client_id)
        return client and client.name or nil
      end,
    notification_group =          -- How to get a progress message's notification group key
      function(msg) return msg.lsp_client.name end,
    ignore = {},                  -- List of LSP servers to ignore

    -- Options related to how LSP progress messages are displayed as notifications
    display = {
      render_limit = 16,          -- How many LSP messages to show at once
      done_ttl = 0.2,               -- How long a message should persist after completion
      done_icon = "",            -- Icon shown when all LSP progress tasks are complete
      done_style = "LineNr",    -- Highlight group for completed LSP tasks
      progress_ttl = math.huge,   -- How long a message should persist when in progress
      progress_icon =             -- Icon shown when LSP progress tasks are in progress
        { "dots" },
      progress_style =            -- Highlight group for in-progress LSP tasks
        "LineNr",
      group_style = "LineNr",      -- Highlight group for group name (LSP server name)
      icon_style = "LineNr",    -- Highlight group for group icons
      priority = 30,              -- Ordering priority for LSP notification group
      skip_history = true,        -- Whether progress notifications should be omitted from history
      format_message =            -- How to format a progress message
        require("fidget.progress.display").default_format_message,
      format_annote =             -- How to format a progress annotation
        function(msg) return msg.title end,
      format_group_name =         -- How to format a progress notification group's name
        function(group) return tostring(group) end,
      overrides = {               -- Override options from the default notification config
        rust_analyzer = { name = "rust-analyzer" },
      },
    },

    -- Options related to Neovim's built-in LSP client
    lsp = {
      progress_ringbuf_size = 0,  -- Configure the nvim's LSP progress ring buffer size
      log_handler = false,        -- Log `$/progress` handler invocations (for debugging)
    },
  },

  -- Options related to notification subsystem
  notification = {
    poll_rate = 10,               -- How frequently to update and render notifications
    filter = vim.log.levels.INFO, -- Minimum notifications level
    history_size = 128,           -- Number of removed messages to retain in history
    override_vim_notify = false,  -- Automatically override vim.notify() with Fidget
    configs =                     -- How to configure notification groups when instantiated
      { default = require("fidget.notification").default_config },
    redirect =                    -- Conditionally redirect notifications to another backend
      function(msg, level, opts)
        if opts and opts.on_open then
          return require("fidget.integration.nvim-notify").delegate(msg, level, opts)
        end
      end,

    -- Options related to how notifications are rendered as text
    view = {
      stack_upwards = true,       -- Display notification items from bottom to top
      icon_separator = " ",       -- Separator between group name and icon
      group_separator = "---",    -- Separator between notification groups
      group_separator_hl =        -- Highlight group used for group separator
        "LineNr",
      render_message =            -- How to render notification messages
        function(msg, cnt)
          return cnt == 1 and msg or string.format("(%dx) %s", cnt, msg)
        end,
    },

    -- Options related to the notification window and buffer
    window = {
      normal_hl = "LineNr",      -- Base highlight group in the notification window
      winblend = 100,             -- Background color opacity in the notification window
      border = "none",            -- Border around the notification window
      zindex = 45,                -- Stacking priority of the notification window
      max_width = 0,              -- Maximum width of the notification window
      max_height = 0,             -- Maximum height of the notification window
      x_padding = 1,              -- Padding from right edge of window boundary
      y_padding = 0,              -- Padding from bottom edge of window boundary
      align = "bottom",           -- How to align the notification window
      relative = "editor",        -- What the notification window position is relative to
    },
  },

  -- Options related to integrating with other plugins
  integration = {
    ["nvim-tree"] = {
      enable = false,              -- Integrate with nvim-tree/nvim-tree.lua (if installed)
    },
    ["xcodebuild-nvim"] = {
      enable = false,              -- Integrate with wojciech-kulik/xcodebuild.nvim (if installed)
    },
  },

  -- Options related to logging
  logger = {
    level = vim.log.levels.WARN,  -- Minimum logging level
    max_size = 10000,             -- Maximum log file size, in KB
    float_precision = 0.01,       -- Limit the number of decimals displayed for floats
    path =                        -- Where Fidget writes its logs to
      string.format("%s/fidget.nvim.log", vim.fn.stdpath("cache")),
  },
})
require("fidget.notification").suppress(true);
require("telescope").load_extension("fidget")
vim.keymap.set("n", "<leader>fm", function()
  require("telescope").extensions.fidget.fidget()
end, { noremap = true, silent = true, desc = "[F]ind (LSP) [M]essages" })


-- [[diagnostics]]

vim.keymap.set("n", "<C-Up>", function() 
  local diagnostic = vim.diagnostic.get_prev()
  if diagnostic ~= nil then
    vim.diagnostic.jump({ diagnostic = diagnostic })
  end
end, { desc = "Go to prev diagnostic" })

vim.keymap.set("n", "<C-Down>", function() 
  local diagnostic = vim.diagnostic.get_next()
  if diagnostic ~= nil then
    vim.diagnostic.jump({ diagnostic = diagnostic })
  end
end, { desc = "Go to next diagnostic" })

vim.keymap.set("n", "<C-Right>", function() tiny_code_action.code_action() end, { desc = "Open LSP code action picker" })
