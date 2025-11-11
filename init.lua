-- bootstrap lazy.nvim, LazyVim and your plugins
if vim.loader then
  vim.loader.enable()
end

_G.dd = function(...)
  require("util.debug").dump(...)
end
vim.print = _G.dd

-- Cargar optimizaciones de rendimiento
require("config.performance")

require("config.lazy")
