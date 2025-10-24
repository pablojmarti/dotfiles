return {
  name = "build depression",
  builder = function()
    -- Full path to current file (see :help expand())
    local file = vim.fn.expand("%:h:h")
    return {
      cmd = { "cmake" },
      args = { "--build", file .."/bin" },
      components = { { "on_output_quickfix", open = true }, "default" },
    }
  end,
  condition = {
    filetype = { "c" },
  },
}
