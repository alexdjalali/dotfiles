-- GoLand/PyCharm equivalents. Run configurations come from overseer.nvim
-- (community.lua, <leader>M*); Refactor This is in productivity.lua and
-- Optimize Imports in astrolsp.lua.
---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    mappings = {
      n = {
        -- Search Everywhere (Shift Shift): files, buffers and recent files
        ["<Leader><Leader>"] = { function() require("snacks").picker.smart() end, desc = "Search everywhere" },
        -- Find Action (Cmd+Shift+A); <leader>fk lists keymaps
        ["<Leader>fA"] = { function() require("snacks").picker.commands() end, desc = "Find action (commands)" },
        -- Run current file (Ctrl+Shift+R) as an overseer task
        ["<Leader>Mf"] = { function() require("ide.run").current_file() end, desc = "Run current file" },
      },
    },
  },
}
