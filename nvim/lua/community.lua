---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.python-ruff" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.terraform" },
  { import = "astrocommunity.pack.yaml" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.bash" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.git.diffview-nvim" },
  -- flash.nvim configured locally in plugins/navigation.lua
  -- { import = "astrocommunity.motion.flash-nvim" },
  { import = "astrocommunity.diagnostics.trouble-nvim" },
  { import = "astrocommunity.editing-support.todo-comments-nvim" },
  { import = "astrocommunity.indent.mini-indentscope" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.helm" },
}
