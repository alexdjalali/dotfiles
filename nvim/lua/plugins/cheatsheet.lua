-- In-editor guides. which-key is the keymap reference: <leader>? lists every
-- mapping under <leader>, each with its desc. The pages below cover workflows a
-- keymap list can't; each is data (a title and sections of lines) rendered by
-- one float helper. tests/nvim/help_spec.lua checks the keys and skills they name.

local pages = {
  spec = {
    title = "Spec pipeline",
    sections = {
      { "Flow", {
        "/adr → /arch → /rfp → /spec (per story) → /github",
        "decide → diagram → stories → plan, implement, verify → ship",
        "/roadmap orders epics above /rfp; /design-doc sits between /adr and /spec",
      } },
      { "Plan and build", {
        "/spec <story|task>     plan → [you approve] → implement → verify",
        "/spec-plan  /spec-implement  /spec-verify     the phases /spec chains",
        "/spec-bugfix-plan  /spec-bugfix-verify        the bugfix lane",
        "/tdd                   one red → green → refactor cycle",
      } },
      { "Bugs", {
        "/investigate           cause unknown: reproduce, isolate, fix",
        "/fix                   cause known: reproducing test + small fix",
        "/rca                   diagnosis only, file:line cited",
      } },
      { "Review and ship", {
        "/review-diff           two-pass review of any diff",
        "quality gates          the project's own gate, else format/lint/types/tests",
        "/github                branch, commit, PR (each git write confirmed)",
      } },
      { "Artifacts and upkeep", {
        "/audit  /demo  /program-status  /sync-docs  /patterns",
        "/repo                  scaffold or audit a repo layout",
        "/learn  /vault         keep a reusable skill or a snippet",
        "docs/adr, docs/spec/{arch,epics,stories,rca,audits,...}",
        "docs/local/plans       plans (gitignored)",
      } },
    },
  },
  data = {
    title = "Data and infrastructure tools",
    sections = {
      { "Databases (vim-dadbod-ui)", {
        "<leader>D     toggle the database UI",
        "a  d  R       add, delete, rename a connection",
        "<CR>          expand, or run the query under the cursor;  W saves it",
        "Connections: a project's .nvim.lua sets vim.g.dbs, or add one in the UI",
        "postgres://user@host:5432/db   mongodb://host:27017/db   redis://host:6379",
      } },
      { "Floating TUIs", {
        "<leader>Ld  LazyDocker        <leader>Lk  K9s",
        "<leader>Ls  LazySql           <leader>Lv  ViMongo",
        "<leader>Lt  Ktea (Kafka)      <leader>Le  Elasticsearch REPL",
        "<leader>Lb  Btop              <leader>Lm  Neomutt",
        "<leader>Ln  Neo4j client: prompts for the password;",
        "            NEO4J_USERNAME and NEO4J_URI pick the user and server",
      } },
      { "Elasticsearch REPL", {
        "GET /_cat/indices?v      GET /_cluster/health",
        "POST /my-index/_search {\"query\": {\"match_all\": {}}}",
      } },
      { "Neo4j (Cypher)", {
        "MATCH (n) RETURN labels(n), count(*);",
        ":help   :quit",
      } },
    },
  },
  latex = {
    title = "LaTeX",
    sections = {
      { "Build and view (VimTeX; <localleader> is ,)", {
        ",ll   start/stop the continuous build     ,lv   forward search to Skim",
        ",le   errors      ,lt   table of contents     ,lk   stop",
        ",lc   clean aux files     ,lC   clean aux files and the PDF",
        "Skim: Cmd-Shift-click jumps back to the source line",
      } },
      { "Text objects and motions", {
        "ie ae  environment     ic ac  command     id ad  delimiter",
        "dse cse tse   delete, change, toggle-star the environment",
        "dsc csc tsc   the same for the command",
        "]] [[  sections        ]m [m  environments",
      } },
      { "LSP (texlab)", {
        "gd  definition     gr  references     K  hover",
        "Completion covers labels, citations and commands",
        "VimTeX builds; texlab builds only on :TexlabBuild",
      } },
      { "Snippets (nvim/snippets/tex)", {
        "TikZ     tikzpic tikznode tikzdraw tikzcd tikzflow pgfaxis pgfbar pgffig",
        "Beamer   beamerdoc frame framefrag columns block bitem pause only",
        "Packages article btable si cref fig subfig algo minted eq align thm",
      } },
      { "latexmk (~/.latexmkrc)", {
        "pdflatex with SyncTeX; biber/bibtex runs only when a .bib changes",
        "Shell escape is off. For minted or TikZ externalization, add a",
        "latexmkrc beside the .tex (see the comment in latex/.latexmkrc)",
      } },
    },
  },
}

-- Render a page in a centered float; q or <Esc> closes it.
local function show(page)
  local lines = {}
  for _, section in ipairs(page.sections) do
    table.insert(lines, section[1])
    for _, line in ipairs(section[2]) do
      table.insert(lines, "  " .. line)
    end
    table.insert(lines, "")
  end
  table.insert(lines, "q or <Esc> closes")

  local width = 0
  for _, line in ipairs(lines) do
    width = math.max(width, vim.fn.strdisplaywidth(line))
  end
  width = math.min(width + 2, vim.o.columns - 4)
  local height = math.min(#lines, vim.o.lines - 4)

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"
  vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = math.floor((vim.o.lines - height) / 2),
    col = math.floor((vim.o.columns - width) / 2),
    style = "minimal",
    border = "rounded",
    title = " " .. page.title .. " ",
    title_pos = "center",
  })
  for _, key in ipairs({ "q", "<Esc>" }) do
    vim.keymap.set("n", key, "<cmd>close<cr>", { buffer = buf, nowait = true })
  end
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = function(_, opts)
    opts.mappings = opts.mappings or {}
    opts.mappings.n = opts.mappings.n or {}
    local maps = opts.mappings.n
    maps["<leader>?"] = { function() require("which-key").show({ keys = "<leader>" }) end, desc = "Keymaps (which-key)" }
    maps["<leader>W"] = { desc = "Workflow guides" }
    maps["<leader>Ws"] = { function() show(pages.spec) end, desc = "Spec pipeline guide" }
    maps["<leader>Wd"] = { function() show(pages.data) end, desc = "Data and infrastructure guide" }
    maps["<leader>Wt"] = { function() show(pages.latex) end, desc = "LaTeX guide" }
  end,
}
