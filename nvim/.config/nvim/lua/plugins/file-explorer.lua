return {
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      view = { width = 30, side = "left" },
      renderer = { group_empty = true },
      filters = { dotfiles = false },
    },
  },
}
