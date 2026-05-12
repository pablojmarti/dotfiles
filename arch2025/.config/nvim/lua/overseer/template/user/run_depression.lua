return {
  name = "run depression",
  builder = function()
    -- Full path to current file (see :help expand())
    local path = vim.fn.expand("%:h:h")
    local cmd = { "./bin/depression" }
    return {
      cmd = cmd,
      components = { { "on_output_quickfix", open = true }, "default" },
    }
  end,
}
