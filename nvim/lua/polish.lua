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

-- Workaround: Neovim's OSC 133 prompt-mark handler (still shipped in 0.12.5)
-- calls nvim_buf_set_extmark with an out-of-range line once terminal scrollback
-- is trimmed. Delete this block when a release notes the fix (:h osc133).
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

-- Guard the built-in comment operator, which raises a Lua traceback ("Buffer is
-- not 'modifiable'") in read-only buffers. Wrap the default mapping's callback:
-- returning the keys "gc"/"gcc" from a noremap expr mapping would run the native
-- `gc`, which is not a command, and silently disable commenting. In a read-only
-- buffer the operator still runs, so it consumes the motion typed after `gc`,
-- but with an operatorfunc that only warns. Only expr defaults are wrapped.
function _G.__dotfiles_readonly_comment() vim.notify("Buffer is not modifiable", vim.log.levels.WARN) end
local function guard_comment(mode, lhs)
  local default = vim.fn.maparg(lhs, mode, false, true)
  if not default.callback or default.expr ~= 1 then return end
  vim.keymap.set(mode, lhs, function()
    if vim.bo.modifiable then return default.callback() end
    vim.o.operatorfunc = "v:lua.__dotfiles_readonly_comment"
    return lhs == "gcc" and "g@_" or "g@"
  end, { expr = true, desc = default.desc })
end
guard_comment("n", "gc")
guard_comment("x", "gc")
guard_comment("n", "gcc")
