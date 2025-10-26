require("pablomarticordero.set")
require("pablomarticordero.remap")
require("pablomarticordero.lsp")

local augroup = vim.api.nvim_create_augroup
local pmcGroup = augroup('pmcGroup', {})
local autocmd = vim.api.nvim_create_autocmd

--- Disable auto comments 
autocmd('FileType', {
  group = pmcGroup,
  pattern = "*",
  command ="setlocal formatoptions-=c formatoptions-=r formatoptions-=o"
})

autocmd('LspAttach', {
  group = pmcGroup,
  callback = function(e)
    local opts = { buffer = e.buf }
    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end, opts)
    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)
    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
  end
})

-- Automatically build on file save
vim.api.nvim_create_user_command("WatchDepression", function()
  local overseer = require("overseer")
  overseer.run_template({ name = "build depression" }, function(task)
    if task then
      task:add_component({ "restart_on_save", paths = {vim.fn.expand("%:h")} })
      local main_win = vim.api.nvim_get_current_win()
      vim.api.nvim_set_current_win(main_win)
    else
      vim.notify("WatchRun not supported for filetype " .. vim.bo.filetype, vim.log.levels.ERROR)
    end
  end)
end, {})
