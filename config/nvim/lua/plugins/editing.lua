return {
  {
    -- Auto-close brackets and quotes
    "nvim-mini/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },
  {
    -- Add, change or delete surroundings: ys{motion}{char}, cs{old}{new}, ds{char}
    "kylechui/nvim-surround",
    version = "^4.0.0",
    event = "VeryLazy",
  },
}
