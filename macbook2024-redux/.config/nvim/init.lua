require("config.darkermatrix").setup()
require("config.lazy")
require("pablomarticordero")

require("overseer").setup({
  templates = { "builtin", "user.c_build", "user.run_depression" },
  task_list = {
    max_width = 0.1,
  },
})

require('nvim-treesitter').setup {
  -- Directory to install parsers and queries to (prepended to `runtimepath` to have priority)
  install_dir = vim.fn.stdpath('data') .. '/site'
}

vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'c' },
  callback = function() vim.treesitter.start() end,
})

vim.lsp.enable('luals')
vim.lsp.enable('pyright')
require('lsp.c-enhanced')

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- empty setup using defaults
require("nvim-tree").setup()
