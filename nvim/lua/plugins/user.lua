-- Floating TUI tools and the Pilot split, registered by the toggleterm spec
-- below once toggleterm has loaded.

-- Full-screen TUIs, one :Command each. `cmd` may be a function, evaluated on
-- first use.
local tools = {
  { name = "LazyDocker", cmd = "lazydocker" },
  { name = "K9s", cmd = "k9s" },
  { name = "LazySql", cmd = "lazysql" },
  { name = "Btop", cmd = "btop" },
  { name = "ViMongo", cmd = "vi-mongo" },
  { name = "Ktea", cmd = "ktea" },
  { name = "ElasticCli", cmd = "elasticsearch-cli --host http://localhost:9200" },
  -- neo4j-client takes a password only as a flag or at its prompt (-P); it prompts.
  {
    name = "Neo4jCli",
    cmd = function()
      local user = vim.env.NEO4J_USERNAME or "neo4j"
      local uri = vim.env.NEO4J_URI or "neo4j://localhost:7687"
      return ("neo4j-client -P -u %s %s"):format(vim.fn.shellescape(user), vim.fn.shellescape(uri))
    end,
  },
}

local function startinsert() vim.cmd("startinsert!") end

local function register_tools(Terminal)
  for _, tool in ipairs(tools) do
    local term
    vim.api.nvim_create_user_command(tool.name, function()
      if not term then
        local cmd = type(tool.cmd) == "function" and tool.cmd() or tool.cmd
        term = Terminal:new({ cmd = cmd, direction = "float", hidden = true, on_open = startinsert })
      end
      term:toggle()
    end, { desc = "Toggle " .. tool.name })
  end
end

-- Pilot: Claude Code in a bottom split (25% height) with a shell beside it.
local function register_pilot(Terminal)
  local claude = vim.fn.exepath("claude") ~= "" and vim.fn.exepath("claude") or "claude"
  local pilot = Terminal:new({ cmd = claude, count = 10, direction = "horizontal", hidden = true, on_open = startinsert })
  local shell = Terminal:new({ count = 11, direction = "horizontal", hidden = true, on_open = startinsert })

  local function open()
    pilot:open(math.floor(vim.o.lines * 0.25), "horizontal")
    vim.cmd("belowright vsplit")
    if not shell.bufnr or not vim.api.nvim_buf_is_valid(shell.bufnr) then
      local buf = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_win_set_buf(0, buf)
      shell.job_id = vim.fn.jobstart(vim.o.shell, { term = true })
      shell.bufnr = buf
    else
      vim.api.nvim_win_set_buf(0, shell.bufnr)
    end
    shell.window = vim.api.nvim_get_current_win()
    vim.cmd("wincmd h")
    vim.cmd("startinsert")
  end

  vim.api.nvim_create_user_command("Pilot", function()
    if not pilot:is_open() then return open() end
    if shell.window and vim.api.nvim_win_is_valid(shell.window) then shell:close() end
    pilot:close()
  end, { desc = "Toggle Claude with a shell beside it" })
  vim.keymap.set("n", "<leader>ac", "<cmd>Pilot<cr>", { desc = "Toggle Claude (split + shell)" })
end

---@type LazySpec
return {
  -- lazygit.nvim
  {
    "kdheepak/lazygit.nvim",
    cmd = "LazyGit",
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- toggleterm.nvim: the terminal, the full-screen TUI tools and Pilot
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    event = "VeryLazy", -- the tool :Commands below exist from startup
    keys = {
      { "<C-`>", "<cmd>ToggleTerm<cr>", desc = "Terminal", mode = { "n", "t" } },
    },
    opts = {
      size = 15,
      direction = "horizontal",
      -- Functions, so toggleterm sizes each float for the window it opens in.
      float_opts = {
        border = "curved",
        width = function() return math.floor(vim.o.columns * 0.9) end,
        height = function() return math.floor(vim.o.lines * 0.9) end,
      },
    },
    config = function(_, opts)
      require("toggleterm").setup(opts)
      local Terminal = require("toggleterm.terminal").Terminal
      register_tools(Terminal)
      register_pilot(Terminal)
    end,
  },

  -- kubectl.nvim - newer but useful for k8s
  {
    "ramilito/kubectl.nvim",
    cmd = "Kubectl",
    keys = {
      { "<leader>k", function() require("kubectl").toggle() end, desc = "Kubectl" },
    },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
  },

  -- vim-dadbod configured in productivity.lua (single source of truth)

  -- firenvim - use Neovim in browser
  {
    "glacambre/firenvim",
    lazy = not vim.g.started_by_firenvim,
    build = function()
      vim.fn["firenvim#install"](0)
    end,
    config = function()
      vim.g.firenvim_config = {
        globalSettings = { alt = "all" },
        localSettings = {
          [".*"] = {
            cmdline = "neovim",
            content = "text",
            priority = 0,
            selector = "textarea",
            takeover = "never",
          },
        },
      }
    end,
  },
}
