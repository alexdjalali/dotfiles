-- Comment-operator specs: `gc`, `gcc` and `<leader>/` must toggle comments in
-- the real config, and must not raise a Lua traceback in non-modifiable buffers.
--
-- Run: nvim --headless -c "luafile tests/nvim/comment_spec.lua"   (or `just test`)
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
local spec = dofile(root .. "/tests/lib/spec.lua")

spec.boot()

--- Open a scratch Lua buffer holding `content`, cursor on line 1.
local function lua_buffer(content)
  vim.cmd.enew()
  vim.bo.buftype = "nofile"
  vim.bo.filetype = "lua"
  vim.api.nvim_buf_set_lines(0, 0, -1, false, content)
  vim.api.nvim_win_set_cursor(0, { 1, 0 })
end

local function buffer_lines() return vim.api.nvim_buf_get_lines(0, 0, -1, false) end

--- Type `keys` as a user would (mappings applied) and run them to completion.
local function type_keys(keys) vim.api.nvim_feedkeys(vim.keycode(keys), "mx", false) end

-- Why this test is important:
--   - gcc is the everyday comment toggle; a wrapper that returned the literal
--     keys "gcc" from a noremap expr mapping turned it into a silent no-op.
-- What it tests:
--   - gcc comments an uncommented Lua line, and a second gcc restores it.
spec.it("gcc toggles a line comment", function()
  lua_buffer({ "local x = 1" })
  type_keys("gcc")
  spec.eq({ "-- local x = 1" }, buffer_lines(), "first gcc should comment the line")
  type_keys("gcc")
  spec.eq({ "local x = 1" }, buffer_lines(), "second gcc should uncomment the line")
end)

-- Why this test is important:
--   - gc is an operator; the same wrapper broke it for every motion, not just gcc.
-- What it tests:
--   - gcj comments the cursor line and the line below it.
spec.it("gc{motion} comments a range", function()
  lua_buffer({ "local a = 1", "local b = 2", "local c = 3" })
  type_keys("gcj")
  spec.eq({ "-- local a = 1", "-- local b = 2", "local c = 3" }, buffer_lines(), "gcj should comment two lines")
end)

-- Why this test is important:
--   - AstroNvim's <leader>/ delegates to gcc with remap, so it inherits any gcc breakage.
-- What it tests:
--   - <leader>/ comments the current line.
spec.it("<leader>/ toggles the current line", function()
  lua_buffer({ "local x = 1" })
  type_keys("<Leader>/")
  spec.eq({ "-- local x = 1" }, buffer_lines(), "<leader>/ should comment the line")
end)

-- Why this test is important:
--   - Neovim's built-in operator raises a Lua traceback ("Buffer is not
--     'modifiable'") in read-only buffers; the config guards against that.
-- What it tests:
--   - gcc in a nomodifiable buffer reports no error and leaves the buffer unchanged.
spec.it("gcc in a nomodifiable buffer does not raise", function()
  lua_buffer({ "local x = 1" })
  vim.bo.modifiable = false
  vim.v.errmsg = ""
  type_keys("gcc")
  spec.eq("", vim.v.errmsg, "gcc should not report an error")
  spec.eq({ "local x = 1" }, buffer_lines(), "buffer should be unchanged")
end)

-- Why this test is important:
--   - When the guard returned "" for `gc` in a read-only buffer, the motion
--     typed after it ran as normal-mode keys (`gcap` became `a` + `p`).
-- What it tests:
--   - gcap in a nomodifiable buffer stays in normal mode, reports no error and
--     leaves the buffer unchanged: the operator consumes its motion.
spec.it("gc{motion} in a nomodifiable buffer consumes the motion", function()
  lua_buffer({ "local x = 1", "", "local y = 2" })
  vim.bo.modifiable = false
  vim.v.errmsg = ""
  type_keys("gcap")
  spec.eq("n", vim.api.nvim_get_mode().mode, "should stay in normal mode")
  spec.eq("", vim.v.errmsg, "gc{motion} should not report an error")
  spec.eq({ "local x = 1", "", "local y = 2" }, buffer_lines(), "buffer should be unchanged")
end)

spec.finish()
