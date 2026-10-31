-- IDE-style spec: the GoLand/PyCharm equivalents (run configurations, run the
-- current file, Refactor This, Optimize Imports, Search Everywhere, Find
-- Action, inline hints) exist and do what their names say.
--
-- Run: `just test` (loads this checkout's nvim/ as the config).
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
local spec = dofile(root .. "/tests/lib/spec.lua")

spec.boot()

local plugins = require("lazy.core.config").plugins
local values = require("lazy.core.plugin").values

-- The normal-mode mapping for `lhs` in a scratch buffer of filetype `ft` (so
-- filetype-scoped lazy keys apply), as maparg's dict.
local function map_in(ft, lhs, mode)
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].filetype = ft
  local map = vim.fn.maparg(vim.keycode(lhs), mode or "n", false, true)
  vim.api.nvim_buf_delete(buf, { force = true })
  return map
end

-- Why this test is important:
--   - GoLand's run configurations (Shift+F10, the run widget) have no
--     equivalent without a task runner; overseer reads justfile, Makefile,
--     npm and go tasks and .vscode/tasks.json.
-- What it tests:
--   - overseer.nvim is in the spec and <leader>Mr opens its task picker.
spec.it("run_configurations_via_overseer", function()
  spec.eq(true, plugins["overseer.nvim"] ~= nil, "overseer.nvim in the spec")
  spec.eq("Run Task", vim.fn.maparg("<leader>Mr", "n", false, true).desc, "<leader>Mr")
end)

-- Why this test is important:
--   - "Run current file" (Ctrl+Shift+R / Ctrl+Shift+F10) is the most used run
--     action in GoLand and PyCharm.
-- What it tests:
--   - <leader>Mf builds `go run .` for Go, `uv run <file>` in a uv project and
--     `python3 <file>` outside one, each in the right directory.
spec.it("run_current_file_command", function()
  local run = require("ide.run")
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir .. "/pkg", "p")
  vim.fn.writefile({ "module x" }, dir .. "/go.mod")
  spec.eq({ cmd = { "go", "run", "." }, cwd = dir .. "/pkg" }, run.command(dir .. "/pkg/main.go", "go"), "go")
  local py = vim.fn.tempname()
  vim.fn.mkdir(py .. "/src", "p")
  spec.eq({ cmd = { "python3", py .. "/src/a.py" }, cwd = py .. "/src" }, run.command(py .. "/src/a.py", "python"), "plain python")
  vim.fn.writefile({ "[project]" }, py .. "/pyproject.toml")
  if vim.fn.executable("uv") == 1 then
    spec.eq({ cmd = { "uv", "run", py .. "/src/a.py" }, cwd = py }, run.command(py .. "/src/a.py", "python"), "uv project")
  end
  spec.eq(nil, run.command(py .. "/notes.txt", "text"), "unsupported filetype")
  spec.eq("Run current file", vim.fn.maparg("<leader>Mf", "n", false, true).desc, "<leader>Mf")
end)

-- Why this test is important:
--   - refactoring.nvim dropped `refactor("Extract Function")` for
--     operator-style functions, so every <leader>r* key raised an error.
-- What it tests:
--   - Each refactoring key is an expr mapping whose callback starts the g@
--     operator in a Go buffer, and <leader>rr ("Refactor This") offers them all.
spec.it("refactor_keys_work", function()
  require("lazy").load({ plugins = { "refactoring.nvim" } })
  for _, k in ipairs({ { "<leader>re", "x" }, { "<leader>rf", "x" }, { "<leader>rv", "x" }, { "<leader>ri", "n" }, { "<leader>rI", "n" } }) do
    local m = map_in("go", k[1], k[2])
    spec.eq(1, m.expr, k[1] .. " is an expr mapping")
    -- "g@" takes a motion; inline refactors return "g@l" (the cursor's symbol).
    spec.eq("g@", (m.callback and m.callback() or ""):sub(1, 2), k[1] .. " starts the operator")
  end
  spec.eq("Refactor This", vim.fn.maparg("<leader>rr", "n", false, true).desc, "<leader>rr")
  spec.eq("Refactor This", vim.fn.maparg("<leader>rr", "x", false, true).desc, "<leader>rr (visual)")
end)

-- Why this test is important:
--   - Ruff's import fixes no longer run on save, so imports need an explicit
--     Optimize Imports (Ctrl+Alt+O) for Go and Python.
-- What it tests:
--   - astrolsp maps <leader>lo to the source.organizeImports code action for
--     servers that offer code actions.
spec.it("optimize_imports_key", function()
  local m = values(plugins["astrolsp"], "opts", false).mappings.n["<Leader>lo"]
  spec.eq("Organize imports", m and m.desc, "<leader>lo desc")
  spec.eq("textDocument/codeAction", m and m.cond, "<leader>lo cond")
end)

-- Why this test is important:
--   - Search Everywhere (Shift Shift) and Find Action (Cmd+Shift+A) are how
--     JetBrains users reach everything.
-- What it tests:
--   - <leader><leader> opens the smart picker and <leader>fA the command picker.
spec.it("search_everywhere_and_find_action", function()
  spec.eq("Search everywhere", vim.fn.maparg("<leader><leader>", "n", false, true).desc, "<leader><leader>")
  spec.eq("Find action (commands)", vim.fn.maparg("<leader>fA", "n", false, true).desc, "<leader>fA")
end)

-- Why this test is important:
--   - GoLand and PyCharm show parameter and type hints inline; gopls and
--     basedpyright were configured to send them, but display was off.
-- What it tests:
--   - astrolsp enables inlay hints.
spec.it("inlay_hints_on", function()
  spec.eq(true, values(plugins["astrolsp"], "opts", false).features.inlay_hints, "astrolsp inlay_hints")
end)

spec.finish()
