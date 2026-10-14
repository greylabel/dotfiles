return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    -- Matches Ghostty (TokyoNight Storm / Day); follows 'background'
    opts = {
      style = "storm",
      light_style = "day",
    },
    config = function(_, opts)
      require("tokyonight").setup(opts)
      vim.cmd.colorscheme("tokyonight")
    end,
  },
}
