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


-- Theme
--------

-- require('github-theme').setup({
--   -- transparent = true,
--   hide_inactive_statusline = false,
-- })
--vim.cmd.colorscheme "github_light"

require("catppuccin").setup({
  flavour = "latte",
  background = {
    light = "latte",
    dark = "mocha",
  },
  transparent_background = false; -- use different plugin
})
vim.cmd.colorscheme "catppuccin"

require'nvim-treesitter.configs'.setup {
  highlight = {
    enable = true,
  },
}

-- gitsigns.nvim
-- -------------

require('gitsigns').setup()


-- Theme Modifications
-- -------------------

vim.api.nvim_set_hl(0, "ColorColumn", { ctermbg=0, bg="#f0f0f0" })
vim.opt.colorcolumn = "80"

-- Telescope
-- ---------


