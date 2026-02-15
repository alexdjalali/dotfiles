---@type LazySpec
return {
  -- vim-terraform - 1k+ stars - Terraform syntax and support
  {
    "hashivim/vim-terraform",
    ft = { "terraform", "tf", "hcl" },
    config = function()
      vim.g.terraform_align = 1
      vim.g.terraform_fmt_on_save = 1
    end,
  },

  -- ansible-vim - 800+ stars - Ansible syntax
  {
    "pearofducks/ansible-vim",
    ft = { "yaml.ansible", "ansible" },
    config = function()
      vim.g.ansible_unindent_after_newline = 1
      vim.g.ansible_attribute_highlight = "ob"
      vim.g.ansible_name_highlight = "b"
      vim.g.ansible_extra_keywords_highlight = 1
    end,
  },

  -- vim-helm - 100+ stars - Helm chart support
  {
    "towolf/vim-helm",
    ft = "helm",
  },
}
