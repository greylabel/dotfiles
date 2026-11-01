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

vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "markdown", "text", "gitcommit" },
  desc = "Soft-wrap prose",
  callback = function()
    vim.opt_local.wrap = true
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = group,
  desc = "Return to the last edit position",
  callback = function(args)
    local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
    local ft = vim.bo[args.buf].filetype
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(args.buf) and ft ~= "gitcommit" and ft ~= "gitrebase" then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
