return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File explorer" },
    },
    opts = {
      disable_netrw = true,
      renderer = { group_empty = true },
      -- Show git-ignored files (node_modules, .venv, build output); `I` hides them
      filters = { git_ignored = false },
    },
  },
}
