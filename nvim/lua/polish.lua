-- Disable swap files
vim.opt.swapfile = false

-- Collapse to a single window when all file buffers are closed.
-- Prevents the "4 duplicate splits" problem where closing every buffer
-- leaves the window layout intact with each pane showing the same
-- fallback buffer.
vim.api.nvim_create_autocmd("BufDelete", {
  callback = function()
    vim.schedule(function()
      -- Count windows that are normal (not floating, not special)
      local normal_wins = {}
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        local cfg = vim.api.nvim_win_get_config(win)
        if cfg.relative == "" then
          table.insert(normal_wins, win)
        end
      end
      if #normal_wins <= 1 then return end

      -- Check if any remaining buffer is a "real" file buffer
      local has_real_buf = false
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        if vim.api.nvim_buf_is_loaded(buf) and vim.bo[buf].buflisted then
          local name = vim.api.nvim_buf_get_name(buf)
          local bt = vim.bo[buf].buftype
          if name ~= "" and bt == "" then
            has_real_buf = true
            break
          end
        end
      end

      if not has_real_buf then
        vim.cmd("only")
      end
    end)
  end,
})

-- Workaround: Neovim 0.11+ TermRequest bug — OSC 133 prompt handler calls
-- nvim_buf_set_extmark with out-of-range line when scrollback is trimmed.
-- TODO: Remove once confirmed fixed in Neovim 0.12+ (check :h osc133)
for _, ac in ipairs(vim.api.nvim_get_autocmds({ event = "TermRequest" })) do
  if ac.desc and ac.desc:match("OSC 133") then
    vim.api.nvim_del_autocmd(ac.id)
    break
  end
end

-- Workaround: Neovim 0.12 throws "Index out of bounds" from the built-in
-- diagnostic handlers when a file is opened (e.g. via Neo-tree) while it still
-- carries a diagnostic whose line number is past the file's last line. The
-- handlers defer display to a BufRead autocmd, then call
--   nvim_buf_get_lines(bufnr, lnum, lnum + 1, true)   -- strict indexing
-- (runtime/lua/vim/diagnostic.lua:1845, M.handlers.underline.show), which
-- errors instead of clamping. Wrapping vim.diagnostic.show does NOT help: the
-- throw escapes through the deferred autocmd, detached from the show() call
-- stack. Instead, guard each built-in handler so it only ever sees in-range
-- diagnostics, dropping stale out-of-bounds ones once the buffer is loaded.
-- The diagnostics themselves stay in the store and redisplay correctly when the
-- source republishes valid line numbers.
-- TODO: Remove once strict indexing is dropped upstream.
local function guard_diagnostic_handler(name)
  local handler = vim.diagnostic.handlers[name]
  if not handler or type(handler.show) ~= "function" then return end
  local orig_show = handler.show
  handler.show = function(namespace, bufnr, diagnostics, opts)
    local b = (bufnr == nil or bufnr == 0) and vim.api.nvim_get_current_buf() or bufnr
    local function run()
      if not vim.api.nvim_buf_is_valid(b) then return end
      local line_count = vim.api.nvim_buf_line_count(b)
      local safe = {}
      for _, d in ipairs(diagnostics) do
        if (d.lnum or 0) < line_count then safe[#safe + 1] = d end
      end
      pcall(orig_show, namespace, b, safe, opts)
    end
    if vim.api.nvim_buf_is_loaded(b) then
      run()
    else
      vim.api.nvim_create_autocmd("BufReadPost", { buffer = b, once = true, callback = run })
    end
  end
end
for _, name in ipairs({ "underline", "virtual_text", "virtual_lines", "signs" }) do
  guard_diagnostic_handler(name)
end

-- Focus window on mouse hover (skip floating windows like Telescope, popups, etc.)
-- Debounced to avoid fighting <C-w> and other keyboard window navigation.
vim.opt.mousemoveevent = true
local mouse_focus_timer = vim.uv.new_timer()
vim.keymap.set("n", "<MouseMove>", function()
  local pos = vim.fn.getmousepos()
  if pos.winid ~= 0 and pos.winid ~= vim.api.nvim_get_current_win() then
    local ok, win_config = pcall(vim.api.nvim_win_get_config, pos.winid)
    if ok and win_config.relative == "" then
      local target = pos.winid
      mouse_focus_timer:stop()
      mouse_focus_timer:start(150, 0, vim.schedule_wrap(function()
        if vim.api.nvim_win_is_valid(target) then
          vim.api.nvim_set_current_win(target)
        end
      end))
    end
  else
    mouse_focus_timer:stop()
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

  -- Vi Mongo terminal
  local vimongo = Terminal.Terminal:new({
    cmd = "vi-mongo",
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

  -- Ktea (Kafka TUI) terminal
  local ktea = Terminal.Terminal:new({
    cmd = "ktea",
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

  vim.api.nvim_create_user_command("ViMongo", function()
    vimongo:toggle()
  end, {})

  vim.api.nvim_create_user_command("Ktea", function()
    ktea:toggle()
  end, {})

  -- Elasticsearch CLI terminal
  local escli = Terminal.Terminal:new({
    cmd = "elasticsearch-cli --host http://localhost:9200",
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

  -- Neo4j client terminal
  local neo4jcli = Terminal.Terminal:new({
    cmd = "neo4j-client neo4j://neo4j:" .. (vim.env.HPC_NEO4J_PASSWORD or "changeme") .. "@localhost:7687",
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

  vim.api.nvim_create_user_command("ElasticCli", function()
    escli:toggle()
  end, {})

  vim.api.nvim_create_user_command("Neo4jCli", function()
    neo4jcli:toggle()
  end, {})
end

-- K8s cluster helpers (pod logs, exec, restart, health)
local function setup_k8s_helpers()
  local status_ok, Terminal = pcall(require, "toggleterm.terminal")
  if not status_ok then
    return
  end

  local float_opts = {
    border = "curved",
    width = math.floor(vim.o.columns * 0.9),
    height = math.floor(vim.o.lines * 0.9),
  }

  -- Get pods across HPC namespaces for picker
  local function get_hpc_pods(callback)
    vim.fn.jobstart(
      "kubectl get pods -A --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name,STATUS:.status.phase' 2>/dev/null"
        .. " | grep -E '^hpc' | grep -v Completed",
      {
        stdout_buffered = true,
        on_stdout = function(_, data)
          local items = {}
          for _, line in ipairs(data) do
            if line ~= "" then
              local ns, name, status = line:match("(%S+)%s+(%S+)%s+(%S+)")
              if ns and name then
                table.insert(items, { ns = ns, name = name, status = status, display = ns .. "/" .. name .. " [" .. (status or "?") .. "]" })
              end
            end
          end
          callback(items)
        end,
      }
    )
  end

  -- Get deployments/statefulsets for restart picker
  local function get_hpc_workloads(callback)
    vim.fn.jobstart(
      "kubectl get deploy,statefulset -A --no-headers -o custom-columns='NS:.metadata.namespace,KIND:.kind,NAME:.metadata.name' 2>/dev/null"
        .. " | grep -E '^hpc'",
      {
        stdout_buffered = true,
        on_stdout = function(_, data)
          local items = {}
          for _, line in ipairs(data) do
            if line ~= "" then
              local ns, kind, name = line:match("(%S+)%s+(%S+)%s+(%S+)")
              if ns and kind and name then
                local k = kind == "StatefulSet" and "statefulset" or "deployment"
                table.insert(items, { ns = ns, kind = k, name = name, display = ns .. "/" .. name .. " (" .. k .. ")" })
              end
            end
          end
          callback(items)
        end,
      }
    )
  end

  -- Pod log viewer: pick a pod, open floating terminal with logs
  vim.api.nvim_create_user_command("HpcLogs", function()
    get_hpc_pods(function(pods)
      if #pods == 0 then
        vim.notify("No HPC pods found", vim.log.levels.WARN)
        return
      end
      vim.schedule(function()
        vim.ui.select(pods, {
          prompt = "Select pod to tail logs:",
          format_item = function(item) return item.display end,
        }, function(choice)
          if not choice then return end
          local cmd = "kubectl logs -f --tail=100 -n " .. choice.ns .. " " .. choice.name
          local term = Terminal.Terminal:new({
            cmd = cmd,
            direction = "float",
            float_opts = float_opts,
            hidden = true,
            close_on_exit = false,
            on_open = function() vim.cmd("startinsert!") end,
          })
          term:toggle()
        end)
      end)
    end)
  end, {})

  -- Pod exec: pick a pod, open floating terminal with shell
  vim.api.nvim_create_user_command("HpcExec", function()
    get_hpc_pods(function(pods)
      if #pods == 0 then
        vim.notify("No HPC pods found", vim.log.levels.WARN)
        return
      end
      vim.schedule(function()
        vim.ui.select(pods, {
          prompt = "Select pod to exec into:",
          format_item = function(item) return item.display end,
        }, function(choice)
          if not choice then return end
          local cmd = "kubectl exec -it -n " .. choice.ns .. " " .. choice.name .. " -- sh -c 'if command -v bash >/dev/null 2>&1; then bash; else sh; fi'"
          local term = Terminal.Terminal:new({
            cmd = cmd,
            direction = "float",
            float_opts = float_opts,
            hidden = true,
            on_open = function() vim.cmd("startinsert!") end,
          })
          term:toggle()
        end)
      end)
    end)
  end, {})

  -- Restart workload: pick a deployment/statefulset, restart it
  vim.api.nvim_create_user_command("HpcRestart", function()
    get_hpc_workloads(function(workloads)
      if #workloads == 0 then
        vim.notify("No HPC workloads found", vim.log.levels.WARN)
        return
      end
      vim.schedule(function()
        vim.ui.select(workloads, {
          prompt = "Select workload to restart:",
          format_item = function(item) return item.display end,
        }, function(choice)
          if not choice then return end
          vim.fn.jobstart(
            "kubectl rollout restart " .. choice.kind .. "/" .. choice.name .. " -n " .. choice.ns,
            {
              on_exit = function(_, code)
                vim.schedule(function()
                  if code == 0 then
                    vim.notify("Restarted " .. choice.kind .. "/" .. choice.name .. " in " .. choice.ns, vim.log.levels.INFO)
                  else
                    vim.notify("Failed to restart " .. choice.name, vim.log.levels.ERROR)
                  end
                end)
              end,
            }
          )
        end)
      end)
    end)
  end, {})

  -- Cluster health: floating popup with pod status across namespaces
  vim.api.nvim_create_user_command("HpcHealth", function()
    vim.fn.jobstart(
      "kubectl get pods -A --no-headers -o custom-columns='NS:.metadata.namespace,NAME:.metadata.name,READY:.status.containerStatuses[0].ready,STATUS:.status.phase,RESTARTS:.status.containerStatuses[0].restartCount,AGE:.metadata.creationTimestamp' 2>/dev/null"
        .. " | grep -E '^hpc' | sort -k1,1 -k2,2",
      {
        stdout_buffered = true,
        on_stdout = function(_, data)
          vim.schedule(function()
            local lines = {
              "╭─────────────────────────────────────────────────────────────────╮",
              "│                    HPC Cluster Health                           │",
              "╰─────────────────────────────────────────────────────────────────╯",
              "",
            }
            local current_ns = ""
            local total, healthy, unhealthy = 0, 0, 0

            for _, line in ipairs(data) do
              if line ~= "" then
                local ns, name, ready, status, restarts = line:match("(%S+)%s+(%S+)%s+(%S+)%s+(%S+)%s+(%S+)")
                if ns and name then
                  if ns ~= current_ns then
                    if current_ns ~= "" then table.insert(lines, "") end
                    current_ns = ns
                    table.insert(lines, "  " .. ns)
                    table.insert(lines, "  " .. string.rep("─", 60))
                  end
                  total = total + 1
                  local icon
                  if status == "Running" and ready == "true" then
                    icon = "  ✓"
                    healthy = healthy + 1
                  elseif status == "Completed" then
                    icon = "  ○"
                    healthy = healthy + 1
                  else
                    icon = "  ✗"
                    unhealthy = unhealthy + 1
                  end
                  local restart_info = ""
                  if restarts and tonumber(restarts) and tonumber(restarts) > 0 then
                    restart_info = "  (restarts: " .. restarts .. ")"
                  end
                  -- Trim pod hash for cleaner display
                  local short = name:gsub("%-[a-f0-9]+-[a-z0-9]+$", ""):gsub("%-[a-f0-9]+$", "")
                  table.insert(lines, string.format("  %s %-30s %-12s%s", icon, short, status, restart_info))
                end
              end
            end

            table.insert(lines, "")
            table.insert(lines, "  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
            table.insert(lines, string.format("  Total: %d   Healthy: %d   Unhealthy: %d", total, healthy, unhealthy))
            table.insert(lines, "")
            table.insert(lines, "  Press q to close")

            local buf = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
            vim.bo[buf].modifiable = false
            vim.bo[buf].bufhidden = "wipe"

            local width = 70
            local height = #lines
            local win = vim.api.nvim_open_win(buf, true, {
              relative = "editor",
              width = width,
              height = height,
              col = math.floor((vim.o.columns - width) / 2),
              row = math.floor((vim.o.lines - height) / 2),
              style = "minimal",
              border = "rounded",
            })

            -- Highlights
            for i, l in ipairs(lines) do
              if l:match("^  hpc") and not l:match("✓") then
                vim.api.nvim_buf_add_highlight(buf, -1, "Title", i - 1, 0, -1)
              elseif l:match("✓") then
                vim.api.nvim_buf_add_highlight(buf, -1, "DiagnosticOk", i - 1, 0, -1)
              elseif l:match("✗") then
                vim.api.nvim_buf_add_highlight(buf, -1, "DiagnosticError", i - 1, 0, -1)
              elseif l:match("○") then
                vim.api.nvim_buf_add_highlight(buf, -1, "Comment", i - 1, 0, -1)
              elseif l:match("Total:") then
                vim.api.nvim_buf_add_highlight(buf, -1, "WarningMsg", i - 1, 0, -1)
              end
            end

            vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
            vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
          end)
        end,
      }
    )
  end, {})
end

-- Pilot (Claude Code wrapper) split terminal setup
local function setup_pilot()
  local status_ok, Terminal = pcall(require, "toggleterm.terminal")
  if not status_ok then
    return
  end

  local pilot_term = Terminal.Terminal:new({
    cmd = vim.fn.exepath("claude") ~= "" and vim.fn.exepath("claude") or "claude",
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

  vim.api.nvim_create_user_command("Pilot", function()
    if pilot_term:is_open() then
      if shell_term.window and vim.api.nvim_win_is_valid(shell_term.window) then
        shell_term:close()
      end
      pilot_term:close()
    else
      -- Open Pilot as bottom split at 25% height
      pilot_term:open(math.floor(vim.o.lines * 0.25), "horizontal")
      -- Vsplit the bottom pane for a side-by-side shell
      vim.cmd("belowright vsplit")
      -- Spawn shell toggleterm buffer if needed, then display it
      if not shell_term.bufnr or not vim.api.nvim_buf_is_valid(shell_term.bufnr) then
        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(0, buf)
        shell_term.job_id = vim.fn.jobstart(vim.o.shell, { term = true })
        shell_term.bufnr = buf
      else
        vim.api.nvim_win_set_buf(0, shell_term.bufnr)
      end
      shell_term.window = vim.api.nvim_get_current_win()
      -- Focus Pilot pane
      vim.cmd("wincmd h")
      vim.cmd("startinsert")
    end
  end, {})

  -- Keymap for quick access
  vim.keymap.set("n", "<leader>ap", "<cmd>Pilot<cr>", { desc = "Toggle Pilot split" })
end

-- Run after toggleterm is loaded (VeryLazy + safe retry)
local function setup_after_toggleterm()
  local ok = pcall(require, "toggleterm.terminal")
  if ok then
    setup_devops_tools()
    setup_k8s_helpers()
    setup_pilot()
  else
    vim.defer_fn(setup_after_toggleterm, 200)
  end
end
vim.defer_fn(setup_after_toggleterm, 100)

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
