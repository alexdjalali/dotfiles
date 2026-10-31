---@type LazySpec
return {
  "AstroNvim/astrocore",
  opts = {
    features = {
      autopairs = true,
      cmp = true,
      diagnostics = { virtual_text = true, virtual_lines = false },
      highlighturl = true,
      notifications = true,
    },
    diagnostics = {
      virtual_text = true,
      underline = true,
    },
    options = {
      opt = {
        relativenumber = true,
        number = true,
        spell = false,
        signcolumn = "yes",
        wrap = false,
        textwidth = 90, -- global default; FileType autocmd below enforces it everywhere
        scrolloff = 8,
        cursorline = true,
        tabstop = 2,
        shiftwidth = 2,
        expandtab = true,
        clipboard = "unnamedplus", -- Use system clipboard
        sessionoptions = "blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions",
        -- Load a project's .nvim.lua once trusted (:trust), for project-only helpers.
        exrc = true,
      },
    },
    autocmds = {
      -- Force textwidth = 90 for every filetype, overriding runtime ftplugins
      -- that set their own (e.g. gitcommit = 72) so `gq` wraps at 90 across the board.
      textwidth_everywhere = {
        {
          event = "FileType",
          pattern = "*",
          desc = "Enforce textwidth = 90 for all filetypes",
          callback = function() vim.opt_local.textwidth = 90 end,
        },
      },
    },
    mappings = {
      n = {
        -- <leader>n is the Neorg, Noice and Neogen prefix, so AstroNvim's
        -- "New File" mapping (a key that is also a prefix) is off; use :enew.
        ["<Leader>n"] = false,
        -- <C-s> in normal/visual mode is AstroNvim's (Force write).
        ["<S-h>"] = { "<cmd>bprevious<cr>", desc = "Prev buffer" },
        ["<S-l>"] = { "<cmd>bnext<cr>", desc = "Next buffer" },
        -- Window navigation (<C-h/j/k/l>) and lazygit (<leader>gg) are AstroNvim's
        -- (smart-splits, toggleterm).
        -- Git
        -- <leader>gD: gitsigns sets <leader>gd (View Git diff) in every git buffer.
        ["<leader>gD"] = { "<cmd>DiffviewOpen<cr>", desc = "Diff view" },
        ["<leader>gh"] = { "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
        -- DevOps & Infrastructure (using <leader>L to avoid conflict with LSP <leader>l)
        ["<leader>L"] = { desc = "DevOps Tools" },
        ["<leader>Ld"] = { "<cmd>LazyDocker<cr>", desc = "LazyDocker" },
        ["<leader>Lk"] = { "<cmd>K9s<cr>", desc = "K9s" },
        -- Database
        ["<leader>Ls"] = { "<cmd>LazySql<cr>", desc = "LazySql" },
        -- MongoDB
        ["<leader>Lv"] = { "<cmd>ViMongo<cr>", desc = "Vi Mongo" },
        -- Kafka
        ["<leader>Lt"] = { "<cmd>Ktea<cr>", desc = "Ktea (Kafka)" },
        -- Elasticsearch
        ["<leader>Le"] = { "<cmd>ElasticCli<cr>", desc = "Elasticsearch CLI" },
        -- Neo4j
        ["<leader>Ln"] = { "<cmd>Neo4jCli<cr>", desc = "Neo4j Client" },
        -- System Monitor
        ["<leader>Lb"] = { "<cmd>Btop<cr>", desc = "Btop (toggle)" },
        -- Email
        ["<leader>Lm"] = { "<cmd>terminal neomutt<cr>", desc = "Neomutt (email)" },
        -- Tasks
        ["<leader>T"] = { function()
          -- Toggle neorg task panel on left
          local wins = vim.api.nvim_list_wins()
          local task_win = nil
          for _, win in ipairs(wins) do
            if vim.api.nvim_win_is_valid(win) then
              local ok, buf = pcall(vim.api.nvim_win_get_buf, win)
              if ok then
                local bufname = vim.api.nvim_buf_get_name(buf)
                if bufname:match("neorg/tasks") then
                  task_win = win
                  break
                end
              end
            end
          end

          if task_win and vim.api.nvim_win_is_valid(task_win) then
            pcall(vim.api.nvim_win_close, task_win, false)
          else
            vim.cmd("leftabove 50vsplit ~/neorg/tasks/index.norg")
            vim.cmd("wincmd H") -- Move window to far left
          end
        end, desc = "Toggle task panel" },
      },
      i = {
        ["<C-s>"] = { "<esc><cmd>w<cr>", desc = "Save" },
      },
    },
  },
}
