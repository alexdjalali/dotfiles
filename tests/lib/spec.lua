-- Minimal runner for headless Neovim specs that exercise the real config.
--
-- Specs run as `nvim --headless -c "luafile <spec>"` (`nvim -l` skips init.lua).
-- A spec loads this file, calls `boot()`, registers cases with `it()`, and ends
-- with `finish()`, which prints a summary and exits non-zero on any failure.
local M = { passed = 0, failed = 0 }

--- Fire the UI-start event a headless instance never receives, so lazy.nvim's
--- VeryLazy plugins load exactly as they do in an interactive session.
function M.boot()
  if vim.g.did_very_lazy then return end
  vim.api.nvim_exec_autocmds("UIEnter", { modeline = false })
  vim.wait(5000, function() return vim.g.did_very_lazy == true end, 20)
end

function M.eq(expected, actual, msg)
  if not vim.deep_equal(expected, actual) then
    error(
      ("%s\n      expected: %s\n      actual:   %s"):format(msg, vim.inspect(expected), vim.inspect(actual)),
      2
    )
  end
end

function M.it(name, fn)
  local ok, err = pcall(fn)
  if ok then
    M.passed = M.passed + 1
    io.stdout:write("  ok    ", name, "\n")
  else
    M.failed = M.failed + 1
    io.stdout:write("  FAIL  ", name, "\n      ", tostring(err), "\n")
  end
end

function M.finish()
  io.stdout:write(("%d passed, %d failed\n"):format(M.passed, M.failed))
  vim.cmd(M.failed > 0 and "cquit 1" or "qall!")
end

return M
