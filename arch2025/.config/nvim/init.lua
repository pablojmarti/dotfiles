require("config.lazy")
require("pablomarticordero")
require("overseer").setup({
  templates = { "builtin", "user.c_build", "user.run_depression" },
  task_list = {
    max_width = 0.1,
  },
})

vim.lsp.enable('luals')
vim.lsp.enable('clangd')
vim.lsp.enable('pyright')
