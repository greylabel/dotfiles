local plugins = {}

for _, module in ipairs({
  "plugins.theme",
  "plugins.file-explorer",
  "plugins.statusline",
  "plugins.treesitter",
  "plugins.telescope",
  "plugins.lsp-config",
  "plugins.completions",
  "plugins.formatting",
  "plugins.git",
}) do
  for _, spec in ipairs(require(module)) do
    table.insert(plugins, spec)
  end
end

return plugins
