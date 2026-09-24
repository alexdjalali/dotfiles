-- Help spec: the in-editor guides only document keys and skills that exist.
--
-- Run: `just test` (loads this checkout's nvim/ as the config).
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
local spec = dofile(root .. "/tests/lib/spec.lua")

spec.boot()

local page_keys = { "<leader>Ws", "<leader>Wd", "<leader>Wt" }

-- The lines of the guide a mapping opens (opened like a user would, then closed).
local function page_lines(lhs)
  local map = vim.fn.maparg(vim.keycode(lhs), "n", false, true)
  assert(map.callback, lhs .. " opens no guide")
  map.callback()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  vim.api.nvim_win_close(0, true)
  return lines
end

-- Whether `lhs` is mapped in normal mode, directly or as a prefix of mappings.
local function resolves(lhs)
  local key = vim.keycode(lhs)
  if vim.fn.maparg(key, "n") ~= "" then return true end
  for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
    if vim.keycode(m.lhs):sub(1, #key) == key then return true end
  end
  return false
end

-- Why this test is important:
--   - The old cheatsheet documented keys that didn't exist (<leader>tt,
--     <leader>nf); a guide that lies is worse than none.
-- What it tests:
--   - Every <leader> key named on each guide page is a mapping (or a prefix of
--     mappings) after startup.
spec.it("documented_keys_resolve", function()
  local missing = {}
  for _, lhs in ipairs(page_keys) do
    for _, line in ipairs(page_lines(lhs)) do
      for key in line:gmatch("<leader>[^%s,/]+") do
        if not resolves(key) then table.insert(missing, lhs .. ": " .. key) end
      end
    end
  end
  spec.eq({}, missing, "documented keys with no mapping")
end)

-- Why this test is important:
--   - Skills get renamed and removed (/debug, /review); the pipeline page must
--     name only ones that exist.
-- What it tests:
--   - Every /name on the spec pipeline page is a .claude/skills/<name>/ directory.
spec.it("documented_skills_exist", function()
  local missing, seen = {}, 0
  for _, line in ipairs(page_lines("<leader>Ws")) do
    for name in (" " .. line):gmatch("%s/(%l[%w%-]*)") do
      seen = seen + 1
      if vim.fn.isdirectory(root .. "/.claude/skills/" .. name) == 0 then table.insert(missing, "/" .. name) end
    end
  end
  spec.eq(true, seen > 0, "the spec page names skills")
  spec.eq({}, missing, "documented skills that don't exist")
end)

-- Why this test is important:
--   - Eight copies of the float/close logic drifted apart; one helper renders all pages.
-- What it tests:
--   - cheatsheet.lua opens windows in exactly one place, and <leader>? is not
--     also a prefix (which would make it wait for a second key).
spec.it("single_float_helper", function()
  local src = table.concat(vim.fn.readfile(root .. "/nvim/lua/plugins/cheatsheet.lua"), "\n")
  local _, opens = src:gsub("nvim_open_win", "")
  spec.eq(1, opens, "nvim_open_win calls in cheatsheet.lua")
  local under = {}
  for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
    if m.lhs:match("^ %?.") then table.insert(under, m.lhs) end
  end
  spec.eq({}, under, "mappings under <leader>? (a direct mapping)")
end)

spec.finish()
