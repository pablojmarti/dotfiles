return {
  name = "build depression",
  builder = function()
    local file = vim.fn.expand("%:h:h")
    return {
      cmd = { "cmake" },
      args = { "--build", file .."/bin" },
      components = {
        { "on_output_quickfix", open = true, set_diagnostics = true },
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  condition = {
    filetype = { "c" },
  },
}
