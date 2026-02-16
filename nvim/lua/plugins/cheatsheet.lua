---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      -- Create function to show custom cheatsheet
      local function show_custom_cheatsheet()
        local lines = {
          "╭─────────────────────────────────────────────────────────╮",
          "│           🚀 DevOps & Productivity Toolkit             │",
          "╰─────────────────────────────────────────────────────────╯",
          "",
          "  Git & Version Control",
          "  ──────────────────────",
          "  <leader>gg    LazyGit           Full Git TUI",
          "  <leader>gd    Diff View         View file diffs",
          "  <leader>gh    File History      Git history for file",
          "  <leader>gb    Git Blame         Toggle inline blame",
          "  ]c / [c       Next/Prev Hunk    Jump between git hunks",
          "",
          "  GitHub (Octo)",
          "  ──────────────",
          "  <leader>go    Octo              Open Octo command list",
          "  <leader>gpl   PR List           List pull requests",
          "  <leader>gpc   PR Create         Create pull request",
          "  <leader>gil   Issue List        List issues",
          "  <leader>gic   Issue Create      Create new issue",
          "",
          "  Merge Conflicts (git-conflict)",
          "  ──────────────────────────────",
          "  <leader>gco   Choose Ours       Accept current changes",
          "  <leader>gct   Choose Theirs     Accept incoming changes",
          "  <leader>gcb   Choose Both       Accept both changes",
          "  <leader>gc0   Choose None       Reject both changes",
          "  <leader>gcl   List Conflicts    Show conflicts in quickfix",
          "  ]x / [x       Next/Prev         Jump between conflicts",
          "",
          "  Containers & Kubernetes",
          "  ───────────────────────",
          "  <leader>Ld    LazyDocker        Docker management TUI",
          "  <leader>Lk    K9s               Kubernetes TUI",
          "  <leader>k     Kubectl           Native K8s interface",
          "  <leader>Lh    Cluster Health    Pod status across namespaces",
          "  <leader>Ll    Pod Logs          Tail logs (picker)",
          "  <leader>Lx    Pod Exec          Shell into pod (picker)",
          "  <leader>Lr    Restart           Restart deployment/sts (picker)",
          "",
          "  Databases & Data Infrastructure",
          "  ───────────────────────────────",
          "  <leader>D     Database UI       DadBod (PG, Mongo, Redis)",
          "  <leader>Ls    LazySql           SQL database TUI",
          "  <leader>Lv    Vi Mongo          MongoDB TUI",
          "  <leader>Le    Elastic CLI       Elasticsearch REPL",
          "  <leader>Ln    Neo4j Client      Neo4j Cypher REPL",
          "  <leader>Lt    Ktea              Kafka TUI (k9s-style)",
          "  <leader>Lb    Btop              System monitor",
          "  <leader>?d    Data Infra        Data tools cheatsheet",
          "",
          "  Email & Communication",
          "  ─────────────────────",
          "  <leader>Lm    Neomutt           Terminal email client",
          "              F2 / ,g            → Switch to Gmail",
          "              F3 / ,t            → Switch to GT",
          "",
          "  Tasks & Notes",
          "  ─────────────",
          "  <leader>T     Task Panel        Toggle Neorg tasks",
          "  <leader>ni    Neorg Index       Open task index",
          "  <leader>nt    Today's Journal   Daily journal",
          "",
          "  Markdown & Docs",
          "  ───────────────",
          "  <leader>mp    Preview           Open markdown in browser",
          "  <leader>ms    Stop Preview      Close markdown preview",
          "              Supports:          README, mermaid, KaTeX",
          "",
          "  Navigation & Search",
          "  ───────────────────",
          "  s + 2 chars   Flash Jump        Jump anywhere (NEW!)",
          "  S             Flash Treesitter  Jump by code structure",
          "  <leader>o     Code Outline      Symbol outline",
          "  <leader>ff    Find Files        Telescope files",
          "  <leader>fw    Find Word         Grep in project",
          "  <leader>ft    Find Todos        Search TODO comments",
          "",
          "  Buffers & Windows",
          "  ─────────────────",
          "  <S-h>         Prev Buffer       Previous buffer",
          "  <S-l>         Next Buffer       Next buffer",
          "  <C-h/j/k/l>   Navigate          Move between windows",
          "",
          "  Harpoon (Quick Files)",
          "  ─────────────────────",
          "  <leader>ha    Add File          Add to harpoon",
          "  <leader>hh    Menu              Show harpoon menu",
          "  <leader>1-4   Jump              Jump to file 1-4",
          "",
          "  Debugging (NEW!)",
          "  ────────────────",
          "  <leader>db    Breakpoint        Toggle breakpoint",
          "  <leader>dc    Continue          Start/continue debug",
          "  <leader>di    Step Into         Step into function",
          "  <leader>do    Step Over         Step over line",
          "  <leader>dt    Terminate         Stop debugging",
          "  <leader>du    Debug UI          Toggle debug UI",
          "",
          "  Refactoring",
          "  ───────────",
          "  <leader>re    Extract Func      Extract to function",
          "  <leader>rv    Extract Var       Extract variable",
          "  <leader>ri    Inline Var        Inline variable",
          "",
          "  Code Tools",
          "  ──────────",
          "  <leader>cs    Code Snapshot     Screenshot selection",
          "  <leader>cS    Save Snapshot     Save to ~/Pictures",
          "",
          "  Diagnostics & Errors",
          "  ────────────────────",
          "  <leader>xx    Diagnostics       Show all diagnostics",
          "  <leader>xX    Buffer Diag       Current buffer only",
          "  <leader>xl    LSP References    Show references",
          "",
          "  AI Assistants",
          "  ─────────────",
          "  <leader>ac    Claude Toggle     Toggle Claude (float)",
          "  <leader>af    Claude Focus      Focus Claude window",
          "  <leader>ar    Claude Resume     Resume last conversation",
          "  <leader>ab    Claude Buffer     Send current file",
          "  <leader>as    Claude Send       Send selection (visual)",
          "  <leader>Ct    Cursor Toggle     Open Cursor Agent (float)",
          "  <leader>Cf    Cursor Fix        Fix error at cursor",
          "  <leader>Cs    Cursor Send       Send selection (visual)",
          "  <leader>Kt    Kilo Toggle       Open Kilo AI (float)",
          "  <leader>Kr    Kilo New          New Kilo session",
          "  <leader>?c    AI Agents Sheet   Full AI agents cheatsheet",
          "",
          "  Visual Enhancements",
          "  ───────────────────",
          "  <leader>tc    Context           Toggle sticky headers",
          "  <leader>tw    Twilight          Dim inactive code",
          "  <leader>ut    Transparency      Toggle transparent bg",
          "  <leader>wp    Window Pick       Visual window select",
          "",
          "  Fun & Games 🎮",
          "  ──────────────",
          "  <leader>fml   Make it Rain      Code rain animation",
          "  <leader>fmg   Game of Life      Conway's Game of Life",
          "  <leader>fv    Vim Be Good       Practice vim motions",
          "  <leader>fl    LeetCode          Solve coding problems",
          "",
          "  Virtual Pets 🦆",
          "  ───────────────",
          "  <leader>dd    Hatch Duck        🦆 Spawn a duck",
          "  <leader>dc    Hatch Cat         🐱 Spawn a cat",
          "  <leader>dg    Hatch Dog         🐶 Spawn a dog",
          "  <leader>dr    Hatch Crab        🦀 Spawn a crab",
          "  <leader>ds    Hatch Snake       🐍 Spawn a snake",
          "  <leader>dk    Cook One          Remove one pet",
          "  <leader>da    Cook All          Remove all pets",
          "",
          "  Help Cheatsheets",
          "  ────────────────",
          "  <leader>?     DevOps tools      This window (you are here)",
          "  <leader>??    Vim essentials    Basic Neovim commands",
          "  <leader>?l    Languages         Go & Python shortcuts",
          "  <leader>?w    Workflows         Step-by-step guides",
          "  <leader>?d    Data Infra        DB, Kafka, Redis tools",
          "  <leader>?c    AI Agents         Claude, Cursor, Kilo keys",
          "",
          "  Press <Esc> or q to close this window",
          "",
        }

        -- Create buffer
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        vim.api.nvim_buf_set_option(buf, "filetype", "cheatsheet")

        -- Calculate window size
        local width = 61
        local height = #lines
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)

        -- Create window
        local win_opts = {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded",
        }

        local win = vim.api.nvim_open_win(buf, true, win_opts)

        -- Set window options
        vim.api.nvim_win_set_option(win, "winblend", 0)
        vim.api.nvim_win_set_option(win, "cursorline", false)

        -- Set highlights
        vim.api.nvim_buf_add_highlight(buf, -1, "Title", 1, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 0, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 2, 0, -1)

        -- Highlight section headers
        for i, line in ipairs(lines) do
          if line:match("^  %w") and not line:match("^  <leader>") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Function", i - 1, 0, -1)
          end
          if line:match("^  <leader>") or line:match("^  <S%-") or line:match("^  <C%-") or line:match("^  F%d") then
            vim.api.nvim_buf_add_highlight(buf, -1, "String", i - 1, 2, 16)
          end
        end

        -- Close on q or Esc
        vim.keymap.set("n", "q", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })

        vim.keymap.set("n", "<Esc>", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })
      end

      -- Create function for essential Neovim commands
      local function show_essential_commands()
        local lines = {
          "╭─────────────────────────────────────────────────────────╮",
          "│           ⚡ Essential Neovim Commands                 │",
          "╰─────────────────────────────────────────────────────────╯",
          "",
          "  Navigation (Motion)",
          "  ───────────────────",
          "  h j k l       Left/Down/Up/Right   Basic movement",
          "  w / b         Word forward/back     Jump by word",
          "  gg / G        Top/Bottom            Jump to start/end",
          "  0 / $         Line start/end        Beginning/end of line",
          "  { / }         Paragraph up/down     Jump paragraphs",
          "  Ctrl-u/d      Half page up/down     Scroll pages",
          "  % (on brace)  Match bracket         Jump to matching bracket",
          "",
          "  Window Navigation",
          "  ─────────────────",
          "  Ctrl-h/j/k/l  Move windows          Jump between splits",
          "  Ctrl-w s      Split horizontal      New horizontal split",
          "  Ctrl-w v      Split vertical        New vertical split",
          "  Ctrl-w q      Close window          Close current split",
          "  Ctrl-w o      Only                  Close all but current",
          "",
          "  File Explorer (Neo-tree)",
          "  ─────────────────────────",
          "  <leader>e     Toggle explorer       Show/hide file tree",
          "  a             Add file/folder       Create new",
          "  d             Delete                Delete file/folder",
          "  r             Rename                Rename file/folder",
          "  x             Cut                   Cut to clipboard",
          "  c             Copy                  Copy to clipboard",
          "  p             Paste                 Paste from clipboard",
          "",
          "  Code Folding",
          "  ────────────",
          "  za            Toggle fold           Open/close current fold",
          "  zA            Toggle recursive      Toggle all nested folds",
          "  zR            Open all folds        Expand everything",
          "  zM            Close all folds       Collapse everything",
          "  zc            Close fold            Close current fold",
          "  zo            Open fold             Open current fold",
          "",
          "  Editing",
          "  ───────",
          "  i / a         Insert/Append         Start insert mode",
          "  I / A         Line start/end        Insert at line edges",
          "  o / O         New line below/above  Create new line",
          "  x / X         Delete char           Delete forward/back",
          "  dd            Delete line           Cut entire line",
          "  yy            Yank line             Copy entire line",
          "  p / P         Paste after/before    Paste content",
          "  u / Ctrl-r    Undo/Redo             Undo and redo",
          "",
          "  Visual Mode",
          "  ───────────",
          "  v             Visual                Select characters",
          "  V             Visual Line           Select lines",
          "  Ctrl-v        Visual Block          Select block/column",
          "  gv            Reselect              Re-select last selection",
          "",
          "  Search & Replace",
          "  ────────────────",
          "  /pattern      Search forward        Find text forward",
          "  ?pattern      Search backward       Find text backward",
          "  n / N         Next/Previous         Jump to matches",
          "  *             Search word           Find word under cursor",
          "  :%s/old/new/g Global replace        Replace in file",
          "",
          "  Buffers & Tabs",
          "  ──────────────",
          "  <S-h>         Previous buffer       Go to prev buffer",
          "  <S-l>         Next buffer           Go to next buffer",
          "  <leader>bd    Delete buffer         Close current buffer",
          "  <leader>bb    Buffer list           Show all buffers",
          "",
          "  Terminal",
          "  ────────",
          "  <C-`>         Toggle terminal       Open/close terminal",
          "  <C-`> (in t)  Close terminal        Exit from terminal mode",
          "",
          "  LSP & Completion",
          "  ────────────────",
          "  gd            Go to definition      Jump to definition",
          "  gr            References            Show all references",
          "  K             Hover doc             Show documentation",
          "  <leader>la    Code actions          Show code actions",
          "  <leader>lr    Rename symbol         Rename across files",
          "",
          "  Saving & Quitting",
          "  ─────────────────",
          "  :w / <C-s>    Save                  Write file",
          "  :q            Quit                  Close window",
          "  :wq / ZZ      Save & quit           Write and close",
          "  :q! / ZQ      Quit no save          Close without saving",
          "",
          "  Help Cheatsheets",
          "  ────────────────",
          "  <leader>?     DevOps tools          Productivity & tools",
          "  <leader>??    Vim essentials        This window (you are here)",
          "  <leader>?l    Languages             Go & Python shortcuts",
          "  <leader>?w    Workflows             Step-by-step guides",
          "  <leader>?d    Data Infra            DB, Kafka, Redis tools",
          "  <leader>?c    Cursor Agent          Cursor CLI agent keys",
          "",
          "  Press <Esc> or q to close this window",
          "",
        }

        -- Create buffer
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        vim.api.nvim_buf_set_option(buf, "filetype", "cheatsheet")

        -- Calculate window size (slightly wider for this one)
        local width = 61
        local height = math.min(#lines, vim.o.lines - 4)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)

        -- Create window
        local win_opts = {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded",
        }

        local win = vim.api.nvim_open_win(buf, true, win_opts)

        -- Set window options
        vim.api.nvim_win_set_option(win, "winblend", 0)
        vim.api.nvim_win_set_option(win, "cursorline", false)

        -- Set highlights
        vim.api.nvim_buf_add_highlight(buf, -1, "Title", 1, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 0, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 2, 0, -1)

        -- Highlight section headers
        for i, line in ipairs(lines) do
          if line:match("^  [%w%s%(%)]+$") or line:match("^  [%w%s]+%s*$") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Function", i - 1, 0, -1)
          end
          -- Highlight keybindings
          if line:match("^  [<>%w%-%s/]+%s+") then
            vim.api.nvim_buf_add_highlight(buf, -1, "String", i - 1, 2, 18)
          end
        end

        -- Close on q or Esc
        vim.keymap.set("n", "q", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })

        vim.keymap.set("n", "<Esc>", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })
      end

      -- Create function for language-specific shortcuts
      local function show_language_cheatsheet()
        local lines = {
          "╭─────────────────────────────────────────────────────────╮",
          "│           🔧 Language-Specific Shortcuts                │",
          "╰─────────────────────────────────────────────────────────╯",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │                    🐹 Go Development                  │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  Struct Tags (gopher.nvim)",
          "  ─────────────────────────",
          "  <leader>Gt    Add json tags     Add json struct tags",
          "  <leader>GT    Remove json       Remove json tags",
          "  <leader>Gy    Add yaml tags     Add yaml struct tags",
          "  <leader>Gx    Clear all tags    Remove all struct tags",
          "",
          "  Code Generation",
          "  ───────────────",
          "  <leader>Gi    Implement         Implement interface stubs",
          "  <leader>Ge    If err            Generate if err != nil block",
          "  <leader>Gc    Comment           Generate doc comment",
          "  <leader>Gf    Fill struct       Fill struct with defaults",
          "  <leader>Gp    Fill switch       Fill switch cases",
          "",
          "  Testing",
          "  ───────",
          "  <leader>Ga    Add test          Generate test for function",
          "  <leader>GA    Add all tests     Generate tests for all funcs",
          "  <leader>GE    Add exported      Tests for exported funcs only",
          "  <leader>Gv    Alt file          Toggle test ↔ implementation",
          "  <leader>GV    Alt vsplit        Open alt file in vsplit",
          "",
          "  Running & Building",
          "  ──────────────────",
          "  <leader>Gr    Go run            Run current file/package",
          "  <leader>Gs    Go stop           Stop running process",
          "  <leader>Gm    Go mod tidy       Tidy go.mod dependencies",
          "  <leader>Gl    Go lint           Run golangci-lint",
          "  <leader>Gd    Go doc            Show documentation",
          "",
          "  LSP Features (gopls)",
          "  ────────────────────",
          "  gd            Definition        Jump to definition",
          "  gr            References        Find all references",
          "  K             Hover             Show documentation",
          "  <leader>la    Code actions      Organize imports, etc.",
          "  <leader>lr    Rename            Rename symbol",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │                  🐍 Python Development                │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  Virtual Environments",
          "  ────────────────────",
          "  <leader>pv    Select venv       Choose virtualenv (Telescope)",
          "  <leader>pV    Cached venv       Select from cached venvs",
          "                                  Supports: venv, poetry, conda, uv",
          "",
          "  REPL (iron.nvim)",
          "  ────────────────",
          "  <leader>pr    Open REPL         Start IPython/Python REPL",
          "  <leader>pR    Restart REPL      Restart the REPL",
          "  <leader>pH    Hide REPL         Hide REPL window",
          "  <leader>ps    Send selection    Send visual selection to REPL",
          "  <leader>pl    Send line         Send current line to REPL",
          "  <leader>pp    Send paragraph    Send paragraph to REPL",
          "  <leader>pf    Send file         Send entire file to REPL",
          "  <leader>pu    Send until cursor Send from start to cursor",
          "  <leader>pc    Clear REPL        Clear REPL output",
          "  <leader>pq    Quit REPL         Close REPL session",
          "",
          "  Testing (neotest)",
          "  ─────────────────",
          "  <leader>tt    Run nearest       Run test under cursor",
          "  <leader>tf    Run file          Run all tests in file",
          "  <leader>ts    Run suite         Run entire test suite",
          "  <leader>to    Show output       Show test output",
          "  <leader>tS    Stop              Stop running tests",
          "",
          "  LSP Features (basedpyright)",
          "  ───────────────────────────",
          "  gd            Definition        Jump to definition",
          "  gr            References        Find all references",
          "  K             Hover             Show documentation/types",
          "  <leader>la    Code actions      Quick fixes, imports",
          "  <leader>lr    Rename            Rename symbol",
          "",
          "  Documentation (neogen)",
          "  ──────────────────────",
          "  <leader>nf    Function doc      Generate function docstring",
          "  <leader>nc    Class doc         Generate class docstring",
          "  <leader>nt    Type doc          Generate type docstring",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │                  🔍 Static Analysis                   │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  Linters Enabled",
          "  ───────────────",
          "  Go:     golangci-lint (gosec, revive, gocritic, errorlint)",
          "  Python: ruff, mypy, basedpyright",
          "  Shell:  shellcheck",
          "  Docker: hadolint",
          "  YAML:   yamllint",
          "  TF:     tflint",
          "",
          "  Diagnostics",
          "  ───────────",
          "  <leader>xx    All diagnostics   Show all in Trouble",
          "  <leader>xX    Buffer diags      Current buffer only",
          "  ]d / [d       Next/prev         Jump between diagnostics",
          "",
          "  Help Cheatsheets",
          "  ────────────────",
          "  <leader>?     DevOps tools      Productivity & tools",
          "  <leader>??    Vim essentials    Basic Neovim commands",
          "  <leader>?l    Languages         This window (you are here)",
          "  <leader>?w    Workflows         Step-by-step guides",
          "  <leader>?d    Data Infra        DB, Kafka, Redis tools",
          "  <leader>?c    AI Agents         Claude, Cursor, Kilo keys",
          "",
          "  Press <Esc> or q to close this window",
          "",
        }

        -- Create buffer
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        vim.api.nvim_buf_set_option(buf, "filetype", "cheatsheet")

        -- Calculate window size
        local width = 63
        local height = math.min(#lines, vim.o.lines - 4)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)

        -- Create window
        local win_opts = {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded",
        }

        local win = vim.api.nvim_open_win(buf, true, win_opts)

        -- Set window options
        vim.api.nvim_win_set_option(win, "winblend", 0)
        vim.api.nvim_win_set_option(win, "cursorline", false)

        -- Set highlights for title box
        vim.api.nvim_buf_add_highlight(buf, -1, "Title", 1, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 0, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 2, 0, -1)

        -- Highlight section headers and keybindings
        for i, line in ipairs(lines) do
          -- Section boxes (Go/Python/Static Analysis headers)
          if line:match("^  ╭") or line:match("^  │") or line:match("^  ╰") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Function", i - 1, 0, -1)
          end
          -- Sub-section headers
          if line:match("^  [%w%s%(%)]+$") and not line:match("^  ╭") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Type", i - 1, 0, -1)
          end
          -- Keybindings
          if line:match("^  <leader>") or line:match("^  gd") or line:match("^  gr") or line:match("^  K ") or line:match("^  %]") then
            vim.api.nvim_buf_add_highlight(buf, -1, "String", i - 1, 2, 18)
          end
          -- Linter list items
          if line:match("^  Go:") or line:match("^  Python:") or line:match("^  Shell:") or line:match("^  Docker:") or line:match("^  YAML:") or line:match("^  TF:") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Keyword", i - 1, 2, 10)
          end
        end

        -- Close on q or Esc
        vim.keymap.set("n", "q", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })

        vim.keymap.set("n", "<Esc>", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })
      end

      -- Create function for workflow cheatsheet
      local function show_workflow_cheatsheet()
        local lines = {
          "╭─────────────────────────────────────────────────────────╮",
          "│              Workflows (Step-by-Step)                   │",
          "╰─────────────────────────────────────────────────────────╯",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │               Code Review (Octo)                     │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  1. <leader>gpl       List open PRs",
          "  2. <Enter>           Open PR to read description",
          "  3. :Octo pr checkout Clone PR branch locally",
          "  4. :Octo pr changes  List changed files",
          "  5. :Octo review start Begin formal review",
          "  6.  Navigate to line, :Octo comment add",
          "  7. :Octo review submit  Submit (approve/comment)",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │               Feature Branch                         │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  1. <leader>gg        Open LazyGit",
          "  2.  b → new branch   Create feature branch",
          "  3.  ... make changes ...",
          "  4.  <C-s>            Save files",
          "  5. <leader>gg        Stage & commit in LazyGit",
          "  6.  P → push         Push to remote",
          "  7. <leader>gpc       Create PR from Neovim",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │               Debug Session                          │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  1. <leader>db        Set breakpoint on line",
          "  2. <leader>dc        Start/continue debugger (F5)",
          "  3. <leader>do        Step over (F10)",
          "  4. <leader>di        Step into (F11)",
          "  5. <leader>dO        Step out (S-F11)",
          "  6. <leader>dh        Hover variable to inspect",
          "  7. <leader>du        Toggle debug UI (watches/stack)",
          "  8. <leader>dt        Terminate session",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │               Merge Conflict Resolution              │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  1. <leader>gg        Pull/merge in LazyGit",
          "  2. <leader>gcl       List all conflicts in quickfix",
          "  3. ]x                Jump to next conflict",
          "  4.  Review both versions (highlighted inline)",
          "  5. <leader>gco       Choose ours (current)",
          "     <leader>gct       Choose theirs (incoming)",
          "     <leader>gcb       Choose both",
          "     <leader>gc0       Choose none",
          "  6.  Repeat 3-5 for each conflict",
          "  7. <leader>gg        Stage & commit resolution",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │               Refactor                               │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  1. gd                Go to definition",
          "  2. gr                Find all references",
          "  3. <leader>lr        Rename symbol across files",
          "  4.  (visual select) → <leader>ri  Inline variable",
          "  5. <leader>tr        Run nearest test to verify",
          "  6. <leader>xx        Check diagnostics are clean",
          "  7. <leader>gg        Commit the refactor",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │               Infrastructure (Terraform/K8s)         │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  1.  Edit .tf files   (LSP: terraformls)",
          "  2.  :!terraform plan Review planned changes",
          "  3.  :!terraform apply Apply (confirm in terminal)",
          "  4. <leader>Lh        Cluster health → pod status popup",
          "  5. <leader>Ll        Pod logs → pick & tail in float",
          "  6. <leader>Lx        Pod exec → shell into any pod",
          "  7. <leader>Lr        Restart → rollout restart picker",
          "  8. <leader>Ld        LazyDocker → check containers",
          "  9. <leader>Lk        K9s → check pods/services",
          "  10. <leader>k        Kubectl → native K8s commands",
          "  11. <leader>gg       Commit infra changes",
          "",
          "  Help Cheatsheets",
          "  ────────────────",
          "  <leader>?     DevOps tools      Productivity & tools",
          "  <leader>??    Vim essentials    Basic Neovim commands",
          "  <leader>?l    Languages         Go & Python shortcuts",
          "  <leader>?w    Workflows         This window (you are here)",
          "  <leader>?d    Data Infra        DB, Kafka, Redis tools",
          "  <leader>?c    AI Agents         Claude, Cursor, Kilo keys",
          "",
          "  Press <Esc> or q to close this window",
          "",
        }

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        vim.api.nvim_buf_set_option(buf, "filetype", "cheatsheet")

        local width = 63
        local height = math.min(#lines, vim.o.lines - 4)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)

        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded",
        })

        vim.api.nvim_win_set_option(win, "winblend", 0)
        vim.api.nvim_win_set_option(win, "cursorline", false)

        -- Highlights
        vim.api.nvim_buf_add_highlight(buf, -1, "Title", 1, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 0, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 2, 0, -1)

        for i, line in ipairs(lines) do
          if line:match("^  ╭") or line:match("^  │") or line:match("^  ╰") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Function", i - 1, 0, -1)
          end
          if line:match("^  %d+%.") then
            vim.api.nvim_buf_add_highlight(buf, -1, "String", i - 1, 5, 22)
          end
        end

        vim.keymap.set("n", "q", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })

        vim.keymap.set("n", "<Esc>", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })
      end

      -- Create function for data infrastructure cheatsheet
      local function show_data_infra_cheatsheet()
        local lines = {
          "╭─────────────────────────────────────────────────────────╮",
          "│          Data & Infrastructure Tools                    │",
          "╰─────────────────────────────────────────────────────────╯",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │                DadBod (vim-dadbod-ui)                 │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  <leader>D     Toggle DBUI      Open/close database UI",
          "  :DB postgres://user:pw@host/db  Quick query connection",
          "",
          "  In DBUI:",
          "  a             Add connection   Add new DB connection",
          "  d             Delete           Remove connection",
          "  R             Rename           Rename connection",
          "  S             Select database  Switch active DB",
          "  <CR>          Toggle           Expand/collapse or run query",
          "  W             Save query       Save current query to file",
          "",
          "  Supported: PostgreSQL, MongoDB, Redis, MySQL, SQLite",
          "  Connection URLs:",
          "    postgres://user:pass@localhost:5432/mydb",
          "    mongodb://user:pass@localhost:27017/mydb",
          "    redis://localhost:6379",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │                LazySql (SQL TUI)                      │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  <leader>Ls    Launch           Floating SQL browser",
          "",
          "  Connections:  Edit ~/.config/lazysql/config.toml",
          "  Navigate:     Tab/S-Tab between panes",
          "  Query:        Type SQL in query editor, Ctrl-e to run",
          "  Filter:       / to search tables, Ctrl-f for data",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │                Vi Mongo (MongoDB TUI)                 │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  <leader>Lv    Launch           Floating Mongo browser",
          "",
          "  Config:       ~/.config/vi-mongo/config.yml",
          "  Navigation:   vim-style (h/j/k/l)",
          "  Collections:  Browse, query, insert, update, delete",
          "  Query:        JSON filter syntax in query bar",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │                Ktea (Kafka TUI)                       │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  <leader>Lt    Launch           Floating Kafka browser",
          "",
          "  Cluster:      Configure on first launch",
          "  Topics:       Browse, search, create, delete",
          "  Consumers:    View consumer groups & lag",
          "  Connectors:   Manage Kafka Connect (Debezium)",
          "  Messages:     Read from topics, filter by key/value",
          "  Navigation:   k9s-style (? for help inside)",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │                Redis (via DadBod)                     │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  :DB redis://localhost:6379  KEYS *",
          "  :DB redis://localhost:6379  GET mykey",
          "  :DB redis://localhost:6379  HGETALL myhash",
          "",
          "  Or add as connection in DBUI for persistent access",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │             Elasticsearch (elasticsearch-cli)         │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  <leader>Le    Launch           REPL → localhost:9200",
          "",
          "  Kibana-style commands inside the REPL:",
          "    GET /_cat/indices?v",
          "    GET /hpc_transcripts/_search",
          "    POST /hpc_transcripts/_search  {\"query\":{...}}",
          "    GET /_cluster/health",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │             Neo4j (neo4j-client)                      │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  <leader>Ln    Launch           Cypher REPL → bolt:7687",
          "",
          "  Cypher queries inside the REPL:",
          "    MATCH (n) RETURN labels(n), count(*);",
          "    MATCH (n)-[r]->(m) RETURN type(r), count(*);",
          "    :help                 Show available commands",
          "    :quit                 Exit the client",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │                Quick Reference                        │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  <leader>D     DadBod UI        PG + Mongo + Redis",
          "  <leader>Ls    LazySql          SQL databases (PG/MySQL)",
          "  <leader>Lv    Vi Mongo         MongoDB deep-dive",
          "  <leader>Le    Elastic CLI      Elasticsearch REPL",
          "  <leader>Ln    Neo4j Client     Cypher REPL",
          "  <leader>Lt    Ktea             Kafka + Connect (Debezium)",
          "  <leader>Ld    LazyDocker       Container management",
          "  <leader>Lk    K9s              Kubernetes management",
          "",
          "  K8s Quick Actions",
          "  ─────────────────",
          "  <leader>Lh    Cluster Health   Pod status across namespaces",
          "  <leader>Ll    Pod Logs         Pick pod → floating log tail",
          "  <leader>Lx    Pod Exec         Pick pod → floating shell",
          "  <leader>Lr    Restart          Pick workload → rollout restart",
          "",
          "  Help Cheatsheets",
          "  ────────────────",
          "  <leader>?     DevOps tools      Productivity & tools",
          "  <leader>??    Vim essentials    Basic Neovim commands",
          "  <leader>?l    Languages         Go & Python shortcuts",
          "  <leader>?w    Workflows         Step-by-step guides",
          "  <leader>?d    Data Infra        This window (you are here)",
          "  <leader>?c    AI Agents         Claude, Cursor, Kilo keys",
          "",
          "  Press <Esc> or q to close this window",
          "",
        }

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        vim.api.nvim_buf_set_option(buf, "filetype", "cheatsheet")

        local width = 63
        local height = math.min(#lines, vim.o.lines - 4)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)

        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded",
        })

        vim.api.nvim_win_set_option(win, "winblend", 0)
        vim.api.nvim_win_set_option(win, "cursorline", false)

        -- Highlights
        vim.api.nvim_buf_add_highlight(buf, -1, "Title", 1, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 0, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 2, 0, -1)

        for i, line in ipairs(lines) do
          if line:match("^  ╭") or line:match("^  │") or line:match("^  ╰") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Function", i - 1, 0, -1)
          end
          if line:match("^  <leader>") or line:match("^  :DB") then
            vim.api.nvim_buf_add_highlight(buf, -1, "String", i - 1, 2, 18)
          end
          if line:match("^  In DBUI:") or line:match("^  Supported:") or line:match("^  Connection") or line:match("^  Config:") or line:match("^  Navigation:") or line:match("^  Cluster:") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Type", i - 1, 0, -1)
          end
          -- Keybindings inside sections
          if line:match("^  [a-zA-Z<]%s+") and line:match("%s%s%s%s%s") and not line:match("^  ╭") and not line:match("^  Or ") then
            vim.api.nvim_buf_add_highlight(buf, -1, "String", i - 1, 2, 18)
          end
          -- URL lines
          if line:match("postgres://") or line:match("mongodb://") or line:match("redis://") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Keyword", i - 1, 4, -1)
          end
        end

        vim.keymap.set("n", "q", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })

        vim.keymap.set("n", "<Esc>", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })
      end

      -- Create function for AI Agents cheatsheet (Claude, Cursor, Kilo)
      local function show_cursor_agent_cheatsheet()
        local lines = {
          "╭─────────────────────────────────────────────────────────╮",
          "│           AI Coding Agents                              │",
          "╰─────────────────────────────────────────────────────────╯",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │               Claude Code (Anthropic)                 │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  <leader>ac    Toggle Claude     Float terminal (90x90%)",
          "  <leader>af    Focus Claude      Focus existing window",
          "  <leader>ar    Resume            Resume last conversation",
          "  <leader>aC    Continue          Continue last conversation",
          "  <leader>am    Select Model      Pick Claude model",
          "  <leader>ab    Add Buffer        Send current file",
          "  <leader>as    Send Selection    Send visual selection",
          "  <leader>aa    Accept Diff       Accept Claude's diff",
          "  <leader>ad    Deny Diff         Reject Claude's diff",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │               Cursor Agent (CLI)                      │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  <leader>Ct    Toggle            Float terminal (90x80%)",
          "  <leader>Cc    Close             Close agent window",
          "  <leader>Cr    Restart           Start a new session",
          "  <leader>CR    Resume            Resume last session",
          "  <leader>Cl    List Sessions     Show all sessions",
          "  <leader>Cs    Send Selection    Send visual selection",
          "  <leader>Cf    Fix Error         Fix diagnostic at cursor",
          "  <leader>CF    New + Fix Error   New session, fix error",
          "  <leader>Ce    Quick Edit        Edit prompt (visual)",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │               Kilo AI (CLI)                           │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  <leader>Kt    Toggle Kilo       Float terminal (90x80%)",
          "  <leader>Kr    New Session       Fresh Kilo session",
          "",
          "  Inside Kilo TUI:",
          "  Tab             Switch agent     build ↔ plan",
          "  @general        Invoke subagent  Complex searches",
          "",
          "  ╭───────────────────────────────────────────────────────╮",
          "  │               All Three Agents                        │",
          "  ╰───────────────────────────────────────────────────────╯",
          "",
          "  All open in floating terminals. Use <C-\\><C-n> to",
          "  exit terminal insert mode. Toggle key hides/shows.",
          "",
          "  Claude    Full IDE integration (diffs, context, MCP)",
          "  Cursor    Session mgmt, quick edit, error fixing",
          "  Kilo      Lightweight, plan vs build agents, CI/CD",
          "",
          "  Help Cheatsheets",
          "  ────────────────",
          "  <leader>?     DevOps tools      Productivity & tools",
          "  <leader>??    Vim essentials    Basic Neovim commands",
          "  <leader>?l    Languages         Go & Python shortcuts",
          "  <leader>?w    Workflows         Step-by-step guides",
          "  <leader>?d    Data Infra        DB, Kafka, Redis tools",
          "  <leader>?c    AI Agents         This window (you are here)",
          "",
          "  Press <Esc> or q to close this window",
          "",
        }

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.api.nvim_buf_set_option(buf, "modifiable", false)
        vim.api.nvim_buf_set_option(buf, "filetype", "cheatsheet")

        local width = 63
        local height = math.min(#lines, vim.o.lines - 4)
        local row = math.floor((vim.o.lines - height) / 2)
        local col = math.floor((vim.o.columns - width) / 2)

        local win = vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = width,
          height = height,
          row = row,
          col = col,
          style = "minimal",
          border = "rounded",
        })

        vim.api.nvim_win_set_option(win, "winblend", 0)
        vim.api.nvim_win_set_option(win, "cursorline", false)

        -- Highlights
        vim.api.nvim_buf_add_highlight(buf, -1, "Title", 1, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 0, 0, -1)
        vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 2, 0, -1)

        for i, line in ipairs(lines) do
          if line:match("^  ╭") or line:match("^  │") or line:match("^  ╰") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Function", i - 1, 0, -1)
          end
          if line:match("^  [%w%s%(%)]+$") and not line:match("^  ╭") and not line:match("^  The ") and not line:match("^  Auto") and not line:match("^  References") and not line:match("^  Paths") then
            vim.api.nvim_buf_add_highlight(buf, -1, "Type", i - 1, 0, -1)
          end
          if line:match("^  <leader>") then
            vim.api.nvim_buf_add_highlight(buf, -1, "String", i - 1, 2, 18)
          end
          if line:match("^  %d+%.") then
            vim.api.nvim_buf_add_highlight(buf, -1, "String", i - 1, 5, 22)
          end
        end

        vim.keymap.set("n", "q", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })

        vim.keymap.set("n", "<Esc>", function()
          vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })
      end

      -- Add keybinding to opts.mappings
      if not opts.mappings then opts.mappings = {} end
      if not opts.mappings.n then opts.mappings.n = {} end

      opts.mappings.n["<leader>?"] = {
        show_custom_cheatsheet,
        desc = "Show DevOps tools cheatsheet",
      }

      opts.mappings.n["<leader>??"] = {
        show_essential_commands,
        desc = "Show essential Neovim commands",
      }

      opts.mappings.n["<leader>?l"] = {
        show_language_cheatsheet,
        desc = "Show language-specific shortcuts",
      }

      opts.mappings.n["<leader>?w"] = {
        show_workflow_cheatsheet,
        desc = "Show workflow guides",
      }

      opts.mappings.n["<leader>?d"] = {
        show_data_infra_cheatsheet,
        desc = "Show data infrastructure tools",
      }

      opts.mappings.n["<leader>?c"] = {
        show_cursor_agent_cheatsheet,
        desc = "Show AI Agents cheatsheet",
      }

      return opts
    end,
  },
}
