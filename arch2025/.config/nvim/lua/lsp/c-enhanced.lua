-- Enhanced C/C++ LSP configuration for clangd
-- Drop this into your nvim config as lua/lsp/c-enhanced.lua

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()

-- clangd-specific capabilities
local clangd_capabilities = vim.tbl_deep_extend(
  "force",
  {},
  lsp_capabilities,
  {
    textDocument = {
      completion = {
        completionItem = {
          snippetSupport = true,
        },
      },
    },
  }
)

-- clangd setup (nvim 0.11+ API)
vim.lsp.config('clangd', {
  capabilities = vim.tbl_deep_extend(
    "force",
    clangd_capabilities,
    { offsetEncoding = { 'utf-16' } }
  ),

  -- clangd command with useful flags
  cmd = {
    'clangd',
    '--background-index',
    '--clang-tidy',
    '--header-insertion=ivy',
    '--header-insertion-decorators',
    '--inlay-hints',
    '--cross-file-includes',
    '--index',
    '--log=warning',
    '--limit-results=30',
  },

  -- Filetypes
  filetypes = { 'c', 'cpp', 'cxx', 'h', 'hpp', 'hxx', 'objc', 'objcpp' },

  -- Root markers (priority order)
  root_dir = vim.fs.root(
    0,
    { 'compile_commands.json', 'configure.ac', 'Makefile', 'CMakeLists.txt', '.git' }
  ),

  -- Inlay hints for C (types, parameter names)
  inlay_hints = {
    inlineParameters = true,
    inlineTypes = true,
    other = true,
  },

  -- Indexing
  index = {
    buildUp = true,
  },

  -- Diagnostics tuning
  diagnostics = {
    text_document_diagnostics = {
      enabled = true,
      delay = 50,
    },
  },

  -- Environment for clangd to find system headers
  settings = {
    clangd = {
      MACOSX_DEPLOYMENT_TARGET = vim.env.MACOSX_DEPLOYMENT_TARGET or '10.9',
    },
  },
})

-- clang-tidy integration (runs on save/format)
vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
  pattern = { '*.c', '*.cpp', '*.h', '*.hpp' },
  callback = function()
    -- clang-tidy runs automatically via clangd's --clang-tidy flag
    -- but we can trigger it explicitly for immediate feedback
    vim.lsp.buf.code_action({ context = { diagnostics = vim.diagnostic.get(vim.api.nvim_get_current_buf()), only = { 'clang-tidy' } } })
  end,
})

-- clang-format on save
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  pattern = { '*.c', '*.cpp', '*.h', '*.hpp' },
  callback = function()
    vim.lsp.buf.format({
      name = 'clangd',
      async = false,
    })
  end,
})

-- Keymaps for C files (buffer-local)
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('c_lsp_keymaps', { clear = true }),
  callback = function(args)
    local buffer = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client or client.name ~= 'clangd' then
      return
    end

    local opts = { buffer = buffer }

    -- clangd-specific keymaps
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<leader>co', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>cR', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<leader>cr', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<leader>cd', vim.diagnostic.open_float, opts)
    vim.keymap.set('n', '[e', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', ']e', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)
  end,
})
