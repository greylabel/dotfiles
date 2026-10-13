return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "lua", "vim", "vimdoc", "bash", "javascript", "typescript", "json", "yaml", "markdown", "python" },
      highlight = { enable = true },
      indent = { enable = true },
    },
  },
}
