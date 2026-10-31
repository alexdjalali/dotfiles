-- "Run current file" (GoLand/PyCharm Ctrl+Shift+R): the command for a file,
-- and running it as an overseer task so its output lands in the task list.
local M = {}

--- The command that runs `file` of filetype `ft`, or nil when there is none.
--- Go runs the file's package (`go run .` in its directory); Python runs the
--- file with `uv run` from the project root of a uv project (a pyproject.toml
--- with uv installed), otherwise with python3 from the file's directory.
---@param file string absolute path
---@param ft string filetype
---@return { cmd: string[], cwd: string }|nil
function M.command(file, ft)
  local dir = vim.fs.dirname(file)
  if ft == "go" then return { cmd = { "go", "run", "." }, cwd = dir } end
  if ft == "python" then
    local project = vim.fs.root(file, { "pyproject.toml" })
    if project and vim.fn.executable("uv") == 1 then return { cmd = { "uv", "run", file }, cwd = project } end
    return { cmd = { "python3", file }, cwd = dir }
  end
  return nil
end

--- Run the current buffer's file as an overseer task and open the task list.
function M.current_file()
  local file = vim.api.nvim_buf_get_name(0)
  local spec = file ~= "" and M.command(file, vim.bo.filetype) or nil
  if not spec then
    vim.notify("No run command for filetype '" .. vim.bo.filetype .. "'", vim.log.levels.WARN)
    return
  end
  vim.cmd("silent! update")
  local overseer = require("overseer")
  overseer.new_task({ name = "run " .. vim.fs.basename(file), cmd = spec.cmd, cwd = spec.cwd }):start()
  overseer.open({ enter = false })
end

return M
