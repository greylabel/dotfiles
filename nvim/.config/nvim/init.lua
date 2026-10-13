local init_path = debug.getinfo(1, "S").source:sub(2)
local config_dir = vim.fn.fnamemodify(init_path, ":p:h")

package.path = package.path .. ";" .. config_dir .. "/lua/?.lua;"
package.path = package.path .. ";" .. config_dir .. "/lua/?/init.lua;"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("vim-options")
require("lazy").setup(require("plugins"))
