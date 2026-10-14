-- Claude Code <-> Neovim bridge. Claude runs in its own herdr/tmux pane;
-- after <leader>ac, run /ide in that Claude session to connect.
--
-- Loaded only by the keys/commands below; the first one used starts the
-- bridge (localhost WebSocket + ~/.claude/ide lock file). Until then nothing
-- runs. Delete this file to remove it entirely.
return {
  {
    "coder/claudecode.nvim",
    cmd = { "ClaudeCodeStart", "ClaudeCodeStop", "ClaudeCodeStatus" },
    opts = {
      terminal = { provider = "none" },
    },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCodeStart<cr>", desc = "Start Claude bridge" },
      { "<leader>aq", "<cmd>ClaudeCodeStop<cr>", desc = "Stop Claude bridge" },
      { "<leader>ai", "<cmd>ClaudeCodeStatus<cr>", desc = "Claude bridge status" },
      { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add buffer to Claude" },
      { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send selection to Claude" },
      { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept Claude diff" },
      { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Reject Claude diff" },
    },
  },
}
