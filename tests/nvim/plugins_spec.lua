-- Plugin-set spec: one plugin per concern, and the settings and mappings that
-- keep the rest from colliding.
--
-- Run: `just test` (loads this checkout's nvim/ as the config).
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
local spec = dofile(root .. "/tests/lib/spec.lua")

spec.boot()

local plugins = require("lazy.core.config").plugins

-- The candidates from `names` that are enabled in the lazy spec. "snacks.indent"
-- stands for the indent module of snacks.nvim, which has no spec of its own.
local function enabled(names)
  local on = {}
  for _, name in ipairs(names) do
    if name == "snacks.indent" then
      local ok, snacks = pcall(require, "snacks")
      if ok and snacks.config.indent and snacks.config.indent.enabled then table.insert(on, name) end
    elseif plugins[name] then
      table.insert(on, name)
    end
  end
  return on
end

-- Why this test is important:
--   - Two plugins for one job fight over the same buffers, keys and events
--     (two session savers, two tablines, two completion engines).
-- What it tests:
--   - For each concern, exactly the chosen plugin is enabled.
spec.it("one_plugin_per_concern", function()
  local concerns = {
    { "sessions", { "auto-session", "resession.nvim" }, "resession.nvim" },
    { "Go codegen", { "go.nvim", "guihua.lua", "gopher.nvim" }, "gopher.nvim" },
    { "Go tests", { "neotest-go", "neotest-golang" }, "neotest-golang" },
    { "completion", { "nvim-cmp", "blink.cmp" }, "blink.cmp" },
    { "LSP progress", { "fidget.nvim", "noice.nvim" }, "noice.nvim" },
    { "scope guide", { "indent-blankline.nvim", "mini.indentscope", "snacks.indent" }, "snacks.indent" },
    { "outline", { "outline.nvim", "aerial.nvim" }, "aerial.nvim" },
    { "tabline", { "bufferline.nvim", "heirline.nvim" }, "heirline.nvim" },
  }
  local want, got = {}, {}
  for _, c in ipairs(concerns) do
    want[c[1]], got[c[1]] = { c[3] }, enabled(c[2])
  end
  spec.eq(want, got, "enabled plugins per concern")
end)

-- Why this test is important:
--   - AstroNvim's picker is snacks; a handful of mappings still opened
--     Telescope through extension plugins, so two pickers stayed loaded.
-- What it tests:
--   - The Telescope extension plugins are gone, and no mapping or config opens
--     a Telescope picker (`:Telescope`, `TodoTelescope`, `require("telescope")`).
spec.it("pickers_use_snacks", function()
  spec.eq({}, enabled({ "telescope-frecency.nvim", "telescope-live-grep-args.nvim" }), "Telescope extensions")
  local hits = {}
  for _, file in ipairs(vim.fn.globpath(root .. "/nvim/lua", "**/*.lua", false, true)) do
    for i, line in ipairs(vim.fn.readfile(file)) do
      if line:match("<cmd>Telescope") or line:match("TodoTelescope") or line:match('require%("telescope') then
        table.insert(hits, vim.fn.fnamemodify(file, ":t") .. ":" .. i)
      end
    end
  end
  spec.eq({}, hits, "Telescope pickers")
end)

-- Why this test is important:
--   - gopher's build hook `go install`ed the same tools Mason installs, so two
--     copies of each drifted apart.
-- What it tests:
--   - With Mason configured, running gopher.nvim's build hook doesn't run
--     :GoInstallDeps (`go install` of its tools).
spec.it("gopher_build_leaves_tools_to_mason", function()
  local build = plugins["gopher.nvim"].build
  if type(build) ~= "function" then return end
  local ran, cmd = false, vim.cmd
  vim.cmd = setmetatable({ GoInstallDeps = function() ran = true end }, {
    __call = function(_, c) if tostring(c):match("GoInstallDeps") then ran = true else return cmd(c) end end,
    __index = cmd,
  })
  local ok, err = pcall(build)
  vim.cmd = cmd
  assert(ok, err)
  spec.eq(false, ran, "gopher build ran :GoInstallDeps")
end)

-- Why this test is important:
--   - texlab building on save while VimTeX compiles continuously ran two
--     latexmk builds per save.
-- What it tests:
--   - The resolved astrolsp opts don't make texlab build on save.
spec.it("texlab_build_not_on_save", function()
  local opts = require("lazy.core.plugin").values(plugins["astrolsp"], "opts", false)
  spec.eq(false, opts.config.texlab.settings.texlab.build.onSave, "texlab build.onSave")
end)

-- The desc of the normal-mode mapping for `lhs` in a scratch buffer of `ft`
-- (lazy.nvim adds filetype-scoped keys on FileType), or nil.
local function desc_in(ft, lhs)
  local buf = vim.api.nvim_create_buf(true, true)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].filetype = ft
  local map = vim.fn.maparg(vim.keycode(lhs), "n", false, true)
  vim.api.nvim_buf_delete(buf, { force = true })
  return map.desc
end

-- Why this test is important:
--   - A key with two owners silently does whichever mapped last (or waits for
--     a prefix): <leader>ni installed an npm package in JSON buffers instead of
--     opening the Neorg index.
-- What it tests:
--   - Each of the six known collisions has one owner: Neorg keeps <leader>ni/nt
--     in JSON buffers, refactoring keeps <leader>ri in HTTP buffers, Avante's
--     diff doesn't use ]x/[x, <leader>D has no sub-keys, Pilot has one key, and
--     <C-`> is mapped only by the toggleterm spec.
spec.it("no_keymap_collisions", function()
  spec.eq("Neorg index", desc_in("json", "<leader>ni"), "<leader>ni in a JSON buffer")
  spec.eq("Neorg today", desc_in("json", "<leader>nt"), "<leader>nt in a JSON buffer")
  spec.eq("Inline variable", desc_in("http", "<leader>ri"), "<leader>ri in an HTTP buffer")
  local avante = require("lazy.core.plugin").values(plugins["avante.nvim"], "opts", false)
  spec.eq(false, vim.tbl_contains({ "]x", "[x" }, avante.mappings.diff.next), "Avante diff next on ]x")
  spec.eq(false, vim.tbl_contains({ "]x", "[x" }, avante.mappings.diff.prev), "Avante diff prev on [x")
  local d_prefix = {}
  for _, m in ipairs(vim.api.nvim_get_keymap("n")) do
    if m.lhs:match("^ D.") then table.insert(d_prefix, m.lhs) end
  end
  spec.eq({}, d_prefix, "mappings under <leader>D (a direct mapping)")
  spec.eq("", vim.fn.maparg("<leader>ap", "n"), "<leader>ap (second Pilot key)")
  local core = require("lazy.core.plugin").values(plugins["astrocore"], "opts", false)
  spec.eq(nil, (core.mappings.t or {})["<C-`>"], "astrocore <C-`> terminal mapping")
end)

-- Why this test is important:
--   - Build tags set globally (here or by the go pack) make gopls compile
--     tagged files in every Go repo; tags belong to the project that uses them.
-- What it tests:
--   - The resolved gopls settings carry no buildFlags.
spec.it("gopls_has_no_global_build_tags", function()
  local opts = require("lazy.core.plugin").values(plugins["astrolsp"], "opts", false)
  spec.eq(nil, vim.tbl_get(opts, "config", "gopls", "settings", "gopls", "buildFlags"), "gopls buildFlags")
end)

spec.finish()
