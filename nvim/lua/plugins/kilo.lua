-- Kilo AI coding agent integration via snacks.nvim floating terminal
-- Mirrors the Cursor Agent pattern: floating window, toggle, resume.
---@type LazySpec
return {
  {
    "AstroNvim/astrocore",
    opts = function(_, opts)
      if not opts.mappings then opts.mappings = {} end
      if not opts.mappings.n then opts.mappings.n = {} end

      -- Shared snacks terminal key for Kilo (allows toggle-to-hide)
      local kilo_key = "kilo"

      local function toggle_kilo()
        Snacks.terminal.toggle(kilo_key, {
          env = { TERM = "xterm-256color" },
          interactive = true,
          win = {
            position = "float",
            width = 0.9,
            height = 0.8,
            border = "rounded",
          },
        })
      end

      local function kilo_new_session()
        -- Close existing, start fresh
        Snacks.terminal.toggle(kilo_key, {
          env = { TERM = "xterm-256color" },
          interactive = true,
          create = true,
          win = {
            position = "float",
            width = 0.9,
            height = 0.8,
            border = "rounded",
          },
        })
      end

      opts.mappings.n["<leader>K"] = { nil, desc = "Kilo AI" }
      opts.mappings.n["<leader>Kt"] = { toggle_kilo, desc = "Toggle Kilo" }
      opts.mappings.n["<leader>Kr"] = { kilo_new_session, desc = "New Kilo session" }

      return opts
    end,
  },
}
