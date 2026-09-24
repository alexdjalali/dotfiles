-- Tool-terminal and scope spec: the global config defines the general TUI
-- terminals and nothing that belongs to one project.
--
-- Run: `just test` (loads this checkout's nvim/ as the config).
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
local spec = dofile(root .. "/tests/lib/spec.lua")

spec.boot()
-- Give deferred setup a moment, so a command registered late still counts.
vim.wait(1000, function() return vim.fn.exists(":LazyDocker") == 2 end, 20)

-- Why this test is important:
--   - The HPC helpers (kubectl pickers, restarts, a database list with a
--     `changeme` password) only make sense in that one project's repo.
-- What it tests:
--   - None of the HPC commands exist and no global database list is set.
spec.it("hpc_commands_absent", function()
  local present = {}
  for _, name in ipairs({ "HpcLogs", "HpcExec", "HpcRestart", "HpcHealth" }) do
    if vim.fn.exists(":" .. name) == 2 then table.insert(present, name) end
  end
  spec.eq({}, present, "HPC commands defined globally")
  spec.eq(nil, vim.g.dbs, "global vim.g.dbs")
end)

-- Why this test is important:
--   - The general TUI terminals are the part of the old helpers worth keeping;
--     folding them into one table must not lose a command.
-- What it tests:
--   - All eight tool commands are defined after startup.
spec.it("tool_commands_defined", function()
  local missing = {}
  for _, name in ipairs({ "LazyDocker", "K9s", "LazySql", "Btop", "ViMongo", "Ktea", "ElasticCli", "Neo4jCli" }) do
    if vim.fn.exists(":" .. name) ~= 2 then table.insert(missing, name) end
  end
  spec.eq({}, missing, "tool commands not defined")
end)

-- Why this test is important:
--   - Sizes computed once at startup kept a float sized for the window the
--     editor started in, after any resize.
-- What it tests:
--   - Floating terminals take 90% of the current columns and lines, recomputed
--     each time (toggleterm evaluates size functions when a terminal opens).
spec.it("float_size_tracks_columns", function()
  local float = require("toggleterm.config").get("float_opts") or {}
  spec.eq("function", type(float.width), "float width is computed on open")
  spec.eq("function", type(float.height), "float height is computed on open")
  local columns, lines = vim.o.columns, vim.o.lines
  vim.o.columns, vim.o.lines = 100, 40
  local small = { float.width(), float.height() }
  vim.o.columns, vim.o.lines = 200, 60
  local large = { float.width(), float.height() }
  vim.o.columns, vim.o.lines = columns, lines
  spec.eq({ 90, 36 }, small, "float size at 100x40")
  spec.eq({ 180, 54 }, large, "float size at 200x60")
end)

spec.finish()
