local group = vim.api.nvim_create_augroup("user_config", { clear = true })

-- Pick up edits made outside Neovim, e.g. by an agent in another pane
-- ('autoread' is on by default; this makes it check). FocusGained needs
-- focus events from the terminal/multiplexer.
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold", "TermLeave", "TermClose" }, {
  group = group,
  desc = "Reload files changed outside Neovim",
  callback = function()
    if vim.o.buftype ~= "nofile" and vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Highlight yanked text",
  callback = function()
    vim.hl.on_yank()
  end,
})
