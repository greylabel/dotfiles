local function builtin(name, opts)
  return function()
    require("telescope.builtin")[name](opts)
  end
end

return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    keys = {
      { "<leader><space>", builtin("buffers"), desc = "Buffers" },
      { "<leader>ff", builtin("find_files"), desc = "Files" },
      { "<leader>fg", builtin("live_grep"), desc = "Grep" },
      { "<leader>fw", builtin("grep_string"), desc = "Word under cursor" },
      { "<leader>fb", builtin("buffers"), desc = "Buffers" },
      { "<leader>fr", builtin("oldfiles"), desc = "Recent files" },
      { "<leader>fh", builtin("help_tags"), desc = "Help" },
      { "<leader>fk", builtin("keymaps"), desc = "Keymaps" },
      { "<leader>fs", builtin("lsp_document_symbols"), desc = "Document symbols" },
      { "<leader>xx", builtin("diagnostics"), desc = "Workspace diagnostics" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          -- Lua patterns: escape the dot so .github/.gitignore still show
          file_ignore_patterns = { "%.git/", "node_modules/" },
        },
        pickers = {
          find_files = { hidden = true },
        },
      })
      telescope.load_extension("fzf")
    end,
  },
}
