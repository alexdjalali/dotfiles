-- Disable swap files
vim.opt.swapfile = false

-- Focus window on mouse hover (skip floating windows like Telescope, popups, etc.)
vim.opt.mousemoveevent = true
vim.keymap.set("n", "<MouseMove>", function()
  local pos = vim.fn.getmousepos()
  if pos.winid ~= 0 and pos.winid ~= vim.api.nvim_get_current_win() then
    local win_config = vim.api.nvim_win_get_config(pos.winid)
    if win_config.relative == "" then
      vim.schedule(function()
        if vim.api.nvim_win_is_valid(pos.winid) then
          vim.api.nvim_set_current_win(pos.winid)
        end
      end)
    end
  end
end, { silent = true })

-- Disable unused providers
vim.g.loaded_perl_provider = 0

-- Limit terminal scrollback to reduce memory usage
vim.opt.scrollback = 1000

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- Python settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

-- Go settings
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
    vim.opt_local.expandtab = false
  end,
})

-- LazyDocker, K9s, LazySql, and Btop integration
local function setup_devops_tools()
  local status_ok, Terminal = pcall(require, "toggleterm.terminal")
  if not status_ok then
    return
  end

  -- LazyDocker terminal
  local lazydocker = Terminal.Terminal:new({
    cmd = "lazydocker",
    direction = "float",
    float_opts = {
      border = "curved",
      width = math.floor(vim.o.columns * 0.9),
      height = math.floor(vim.o.lines * 0.9),
    },
    hidden = true,
    on_open = function(term)
      vim.cmd("startinsert!")
    end,
  })

  -- K9s terminal
  local k9s = Terminal.Terminal:new({
    cmd = "k9s",
    direction = "float",
    float_opts = {
      border = "curved",
      width = math.floor(vim.o.columns * 0.9),
      height = math.floor(vim.o.lines * 0.9),
    },
    hidden = true,
    on_open = function(term)
      vim.cmd("startinsert!")
    end,
  })

  -- LazySql terminal
  local lazysql = Terminal.Terminal:new({
    cmd = "lazysql",
    direction = "float",
    float_opts = {
      border = "curved",
      width = math.floor(vim.o.columns * 0.9),
      height = math.floor(vim.o.lines * 0.9),
    },
    hidden = true,
    on_open = function(term)
      vim.cmd("startinsert!")
    end,
  })

  -- Btop terminal - floating like other tools
  local btop = Terminal.Terminal:new({
    cmd = "btop",
    direction = "float",
    float_opts = {
      border = "curved",
      width = function() return math.floor(vim.o.columns * 0.9) end,
      height = function() return math.floor(vim.o.lines * 0.9) end,
    },
    hidden = true,
    on_open = function(term)
      vim.cmd("startinsert!")
    end,
  })

  -- Commands
  vim.api.nvim_create_user_command("LazyDocker", function()
    lazydocker:toggle()
  end, {})

  vim.api.nvim_create_user_command("K9s", function()
    k9s:toggle()
  end, {})

  vim.api.nvim_create_user_command("LazySql", function()
    lazysql:toggle()
  end, {})

  vim.api.nvim_create_user_command("Btop", function()
    btop:toggle()
  end, {})
end

-- Claude Code split terminal setup
local function setup_claude_code()
  local status_ok, Terminal = pcall(require, "toggleterm.terminal")
  if not status_ok then
    return
  end

  local claude_term = Terminal.Terminal:new({
    cmd = "claude",
    count = 10,
    direction = "horizontal",
    hidden = true,
    on_open = function()
      vim.cmd("startinsert!")
    end,
  })

  local shell_term = Terminal.Terminal:new({
    count = 11,
    direction = "horizontal",
    hidden = true,
    on_open = function()
      vim.cmd("startinsert!")
    end,
  })

  vim.api.nvim_create_user_command("ClaudeCode", function()
    if claude_term:is_open() then
      if shell_term.window and vim.api.nvim_win_is_valid(shell_term.window) then
        shell_term:close()
      end
      claude_term:close()
    else
      -- Open Claude as bottom split at 25% height
      claude_term:open(math.floor(vim.o.lines * 0.25), "horizontal")
      -- Vsplit the bottom pane for a side-by-side shell
      vim.cmd("belowright vsplit")
      -- Spawn shell toggleterm buffer if needed, then display it
      if not shell_term.bufnr or not vim.api.nvim_buf_is_valid(shell_term.bufnr) then
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(0, buf)
        shell_term.job_id = vim.fn.termopen(vim.o.shell)
        shell_term.bufnr = buf
      else
        vim.api.nvim_win_set_buf(0, shell_term.bufnr)
      end
      shell_term.window = vim.api.nvim_get_current_win()
      -- Focus Claude pane
      vim.cmd("wincmd h")
      vim.cmd("startinsert")
    end
  end, {})

  -- Keymap for quick access
  vim.keymap.set("n", "<leader>ac", "<cmd>ClaudeCode<cr>", { desc = "Toggle Claude Code split" })
end

-- Run after plugins are loaded
vim.defer_fn(setup_devops_tools, 100)
vim.defer_fn(setup_claude_code, 100)

-- Prevent comment errors in non-modifiable buffers
local function safe_comment()
  if vim.bo.modifiable then
    return "gc"
  else
    vim.notify("Buffer is not modifiable", vim.log.levels.WARN)
    return ""
  end
end

vim.keymap.set({ "n", "v" }, "gc", safe_comment, { expr = true, desc = "Comment (safe)" })
vim.keymap.set("n", "gcc", function()
  if vim.bo.modifiable then
    return "gcc"
  else
    vim.notify("Buffer is not modifiable", vim.log.levels.WARN)
    return ""
  end
end, { expr = true, desc = "Comment line (safe)" })
