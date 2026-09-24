-- Startup smoke spec: a session that attaches a UI must survive plugin loading.
--
-- Run: nvim --headless -c "luafile tests/nvim/startup_spec.lua"   (or `just test`)
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
local spec = dofile(root .. "/tests/lib/spec.lua")

spec.boot()

-- Why this test is important:
--   - Avante loads on first use through lazy.nvim's `cmd` stubs; a command left
--     off that list fails with "Not an editor command" in a fresh session.
-- What it tests:
--   - Every Avante* command the plugin defines already exists (as a lazy stub)
--     before avante loads.
spec.it("exposes every Avante command before avante loads", function()
  local avante = require("lazy.core.config").plugins["avante.nvim"]
  spec.eq(nil, avante._.loaded, "avante must not be loaded yet, or the stub check proves nothing")
  local stubs = vim.api.nvim_get_commands({})
  require("lazy").load({ plugins = { "avante.nvim" } })
  local missing = {}
  for name in pairs(vim.api.nvim_get_commands({})) do
    if name:match("^Avante") and not stubs[name] then table.insert(missing, name) end
  end
  table.sort(missing)
  spec.eq({}, missing, "Avante commands without a lazy stub")
end)

-- Why this test is important:
--   - Avante's native modules, overwritten in place by its build step, made
--     macOS SIGKILL every new session that loaded them (then on VeryLazy).
-- What it tests:
--   - After VeryLazy and an explicit avante load, every native module the
--     build produced (lua/*.so) is loaded and nvim keeps running for 3 s. A kill ends the process, which the
--     runner reports as a failure.
spec.it("survives loading avante's native modules", function()
  spec.eq(true, vim.g.did_very_lazy, "VeryLazy should have fired")
  require("lazy").load({ plugins = { "avante.nvim" } })
  vim.wait(3000, function() return false end, 50)
  local dir = require("lazy.core.config").plugins["avante.nvim"].dir
  local built, unloaded = vim.fn.glob(dir .. "/lua/*.so", false, true), {}
  spec.eq(true, #built > 0, "avante's build should have produced native modules")
  for _, so in ipairs(built) do
    local name = vim.fn.fnamemodify(so, ":t:r")
    if not package.loaded[name] then table.insert(unloaded, name) end
  end
  spec.eq({}, unloaded, "native modules that failed to load")
end)

-- Why this test is important:
--   - The root cause of the startup kill: avante's `make` copies its native
--     modules over the old files in place, keeping the inode macOS cached a
--     code signature for. The spec's extra build step must replace them.
-- What it tests:
--   - Avante's post-make build step re-creates every lua/*.so as a new file
--     (new inode) with identical contents.
spec.it("avante build step gives native modules a fresh inode", function()
  local steps = require("lazy.core.config").plugins["avante.nvim"].build
  spec.eq("function", type(steps[2]), "avante should have a post-make build function")
  local dir = vim.fn.tempname()
  vim.fn.mkdir(dir .. "/lua", "p")
  local so = dir .. "/lua/avante_demo.so"
  vim.fn.writefile({ "native" }, so)
  local before = vim.uv.fs_stat(so).ino
  steps[2]({ dir = dir })
  spec.eq({ "native" }, vim.fn.readfile(so), "contents should be unchanged")
  spec.eq(true, vim.uv.fs_stat(so).ino ~= before, "the module should be a new file (new inode)")
  vim.fn.delete(dir, "rf")
end)

spec.finish()
