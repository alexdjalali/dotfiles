-- Plugin-set spec: one plugin per concern, and the settings and mappings that
-- keep the rest from colliding.
--
-- Run: `just test` (loads this checkout's nvim/ as the config).
local root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h:h")
local spec = dofile(root .. "/tests/lib/spec.lua")

spec.boot()

local plugins = require("lazy.core.config").plugins

-- The candidates from `names` that are enabled in the lazy spec. "snacks.<mod>"
-- stands for a module of snacks.nvim (indent, words), which has no spec of its own.
local function enabled(names)
  local on = {}
  for _, name in ipairs(names) do
    local mod = name:match("^snacks%.(.+)$")
    if mod then
      local ok, snacks = pcall(require, "snacks")
      if ok and snacks.config[mod] and snacks.config[mod].enabled then table.insert(on, name) end
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
    { "breadcrumbs", { "barbecue.nvim", "incline.nvim", "dropbar.nvim", "heirline.nvim" }, "heirline.nvim" },
    { "reference highlight", { "vim-illuminate", "snacks.words" }, "snacks.words" },
    { "lazygit launcher", { "lazygit.nvim", "toggleterm.nvim" }, "toggleterm.nvim" },
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
  spec.eq(false, vim.fn.maparg("S", "x", false, true).desc == "Flash Treesitter", "visual S taken by flash (nvim-surround's)")
end)

-- Normal-mode keys from every owner: lazy.nvim `keys` without `ft`, the
-- resolved astrocore and astrolsp mapping tables, and AstroNvim's gitsigns
-- on_attach maps (buffer-local, so they win in every git buffer). Returns
-- { [lhs] = { owner, ... } } with <Leader> spelled as a space.
local function normal_key_owners()
  local Plugin, Keys = require("lazy.core.plugin"), require("lazy.core.handler.keys")
  local owners = {}
  local function add(lhs, who)
    lhs = vim.keycode((lhs:gsub("<[Ll]eader>", " ")))
    owners[lhs] = owners[lhs] or {}
    owners[lhs][who] = true
  end
  for name, p in pairs(plugins) do
    for _, k in pairs(Keys.resolve(Plugin.values(p, "keys", true))) do
      if not k.ft and k.rhs ~= nil and (k.mode or "n") == "n" then add(k.lhs, name) end
    end
  end
  for _, src in ipairs({ "astrocore", "astrolsp" }) do
    local o = Plugin.values(plugins[src], "opts", false)
    for lhs, m in pairs((o.mappings or {}).n or {}) do
      if type(m) == "table" and m[1] ~= nil then add(lhs, src .. ": " .. (m.desc or "?")) end
    end
  end
  local buf = vim.api.nvim_create_buf(false, true)
  local gs = plugins["gitsigns.nvim"] and Plugin.values(plugins["gitsigns.nvim"], "opts", false)
  if gs and gs.on_attach then
    gs.on_attach(buf)
    for _, m in ipairs(vim.api.nvim_buf_get_keymap(buf, "n")) do
      if m.callback or (m.rhs and m.rhs ~= "") then add(m.lhs, "gitsigns: " .. (m.desc or "?")) end
    end
  end
  vim.api.nvim_buf_delete(buf, { force = true })
  return owners
end

-- Why this test is important:
--   - A mapped key that is also the prefix of another (<leader>C force-close
--     vs <leader>Ct Cursor) waits 'timeoutlen' or fires the wrong action, and a
--     key two plugins define does whichever mapped last: <leader>gd opened
--     gitsigns' diff instead of Diffview, <leader>ps sent text to the Python
--     REPL instead of opening Lazy.
-- What it tests:
--   - No normal-mode key is the prefix of another, and no key has two owners
--     except Glance's deliberate gd/gy over the LSP defaults.
spec.it("no_key_shadows_or_double_owners", function()
  local owners = normal_key_owners()
  local shadows, doubles = {}, {}
  for a, wa in pairs(owners) do
    if vim.tbl_count(wa) > 1 and not vim.tbl_contains({ "gd", "gy" }, a) then
      table.insert(doubles, vim.inspect(a) .. " " .. table.concat(vim.tbl_keys(wa), " | "))
    end
    for b in pairs(owners) do
      if a ~= b and #a >= 2 and b:sub(1, #a) == a then
        table.insert(shadows, vim.inspect(a) .. " shadows " .. vim.inspect(b))
      end
    end
  end
  table.sort(shadows)
  table.sort(doubles)
  spec.eq({}, shadows, "keys that are also prefixes")
  spec.eq({}, doubles, "keys with two owners")
end)

-- Why this test is important:
--   - iron.nvim sets its REPL keymaps globally, so its <leader>p* keys replaced
--     AstroNvim's Packages keys (<leader>ps Lazy status) in every buffer once a
--     Python file had been opened.
-- What it tests:
--   - After iron.nvim loads, <leader>ps is still AstroNvim's "Plugins Status".
spec.it("iron_repl_keeps_off_packages_group", function()
  require("lazy").load({ plugins = { "iron.nvim" } })
  spec.eq("Plugins Status", vim.fn.maparg("<leader>ps", "n", false, true).desc, "<leader>ps after iron loads")
end)

-- Why this test is important:
--   - The debugger was set up with the system python3, which has no debugpy, so
--     every Python debug session failed to start.
-- What it tests:
--   - The python launch adapter runs Mason's debugpy-adapter.
spec.it("python_debugger_uses_mason_debugpy", function()
  require("lazy").load({ plugins = { "nvim-dap-python" } })
  local adapter = require("dap").adapters.python
  if type(adapter) == "function" then
    local got
    adapter(function(a) got = a end, { request = "launch" })
    adapter = got
  end
  spec.eq(true, (adapter.command or ""):match("debugpy%-adapter$") ~= nil, "adapter command " .. tostring(adapter.command))
end)

-- Why this test is important:
--   - basedpyright looked for the venv in the cwd, so a session started in a
--     subdirectory type-checked against the wrong (or no) interpreter.
-- What it tests:
--   - before_init points basedpyright at <root_dir>/.venv/bin/python while the
--     cwd is a subdirectory with no venv.
spec.it("basedpyright_uses_root_venv", function()
  local root = vim.fn.tempname()
  vim.fn.mkdir(root .. "/.venv/bin", "p")
  vim.fn.mkdir(root .. "/sub", "p")
  vim.fn.writefile({ "#!/bin/sh" }, root .. "/.venv/bin/python")
  vim.fn.setfperm(root .. "/.venv/bin/python", "rwxr-xr-x")
  local cwd = vim.fn.getcwd()
  vim.cmd.cd(root .. "/sub")
  local opts = require("lazy.core.plugin").values(plugins["astrolsp"], "opts", false)
  local cfg = { root_dir = root, settings = {} }
  local ok, err = pcall(opts.config.basedpyright.before_init, {}, cfg)
  vim.cmd.cd(cwd)
  assert(ok, err)
  spec.eq(root .. "/.venv/bin/python", vim.tbl_get(cfg, "settings", "python", "pythonPath"), "pythonPath")
end)

-- Why this test is important:
--   - mason-null-ls registered a default source for every Mason tool on top of
--     none-ls.lua's list, so goimports, golines, prettier, stylua and others
--     ran twice per save, beside LSPs that already format.
-- What it tests:
--   - Each none-ls source is registered once, Go gets only goimports from
--     none-ls (gopls formats), and Python and Lua get no none-ls formatter
--     (ruff and stylua run as LSPs).
spec.it("one_none_ls_source_per_tool", function()
  require("lazy").load({ plugins = { "none-ls.nvim" } })
  local sources = require("null-ls.sources")
  vim.wait(3000, function() return #sources.get_all() > 0 end, 50)
  local count, twice = {}, {}
  for _, s in ipairs(sources.get_all()) do
    local key = s.name .. ":" .. table.concat(vim.tbl_keys(s.methods), ",")
    count[key] = (count[key] or 0) + 1
    if count[key] == 2 then table.insert(twice, key) end
  end
  spec.eq({}, twice, "none-ls sources registered twice")
  local fmt = require("null-ls").methods.FORMATTING
  local function formatters(ft)
    local names = {}
    for _, s in ipairs(sources.get_available(ft, fmt)) do table.insert(names, s.name) end
    return names
  end
  spec.eq({ "goimports" }, formatters("go"), "none-ls Go formatters")
  spec.eq({}, formatters("python"), "none-ls Python formatters")
  spec.eq({}, formatters("lua"), "none-ls Lua formatters")
end)

-- Why this test is important:
--   - nvim-scrollbar's main branch becomes v2 on 2026-11-16 and rejects this
--     config's v1 options; until then it stops every startup at a
--     hit-enter prompt.
-- What it tests:
--   - nvim-scrollbar tracks its v1 branch.
spec.it("scrollbar_tracks_v1", function()
  spec.eq("v1", plugins["nvim-scrollbar"].branch, "nvim-scrollbar branch")
end)

-- Why this test is important:
--   - A lockfile-only pin of kulala.nvim was undone by the next :Lazy sync,
--     which moved it to a release that prompts for a license token.
-- What it tests:
--   - The kulala.nvim spec itself pins commit dcad056.
spec.it("kulala_pinned_in_spec", function()
  spec.eq("dcad056", (plugins["kulala.nvim"].commit or ""):sub(1, 7), "kulala.nvim commit")
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
