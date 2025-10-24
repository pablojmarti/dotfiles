require("config.lazy")
require("pablomarticordero")
require("overseer").setup({
  templates = { "builtin", "user.c_build" },
})

vim.lsp.enable('luals')
vim.lsp.enable('clangd')
vim.lsp.enable('pyright')
