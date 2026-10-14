local map = vim.keymap.set

-- Shared with config/vim/vimrc
map("n", "<leader>w", "<cmd>w<CR>", { desc = "Write" })
map("n", "<leader>q", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>v", "<cmd>vsplit<CR>", { desc = "Split vertical" })
map("n", "<leader>s", "<cmd>split<CR>", { desc = "Split horizontal" })

-- Windows: Ctrl+hjkl inside Neovim; multiplexer panes use prefix+hjkl
for _, key in ipairs({ "h", "j", "k", "l" }) do
  map("n", "<C-" .. key .. ">", "<C-w>" .. key, { desc = "Window " .. key })
  map("n", "<leader>" .. key, "<C-w>" .. key, { desc = "Window " .. key })
end

map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Diagnostics
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>xq", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Toggles
map("n", "<leader>uw", "<cmd>set wrap!<CR>", { desc = "Toggle wrap" })
map("n", "<leader>uh", function()
  vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
end, { desc = "Toggle inlay hints" })
