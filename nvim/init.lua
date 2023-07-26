-- See https://martinlwx.github.io/en/config-neovim-from-scratch/
--

require('options')
require('keymaps')
require('plugins')
require('colorscheme')

local format_sync_grp = vim.api.nvim_create_augroup("GoFormat", {})
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*.go",
  callback = function()
   require('go.format').goimport()
  end,
  group = format_sync_grp,
})

require('go').setup()
