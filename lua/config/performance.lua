-- Configuraciones adicionales de rendimiento para LoloVim
-- Este archivo contiene optimizaciones para mejorar la velocidad de inicio y respuesta

-- NOTA: Muchas opciones ya están configuradas en options.lua
-- Este archivo solo contiene optimizaciones adicionales específicas de performance

-- 1. Reducir redraw durante macros y comandos
vim.opt.lazyredraw = false -- Desactivado en Neovim moderno, puede causar problemas

-- 2. Optimizar búsqueda y sintaxis
vim.opt.synmaxcol = 300 -- Limitar resaltado de sintaxis a 300 columnas

-- 3. Deshabilitar providers innecesarios para mejor startup
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- 4. Mejor manejo de archivos grandes
local aug = vim.api.nvim_create_augroup("PerformanceOptimizations", { clear = true })

vim.api.nvim_create_autocmd("BufReadPre", {
  group = aug,
  pattern = "*",
  callback = function(ev)
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if ok and stats and stats.size > 1048576 then -- 1MB
      vim.b[ev.buf].large_file = true

      -- Deshabilitar features pesadas
      vim.opt_local.spell = false
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      vim.opt_local.breakindent = false
      vim.opt_local.colorcolumn = ""
      vim.opt_local.statuscolumn = ""
      vim.opt_local.signcolumn = "no"
      vim.opt_local.foldcolumn = "0"
      vim.opt_local.winbar = ""

      -- Deshabilitar algunos eventos
      vim.api.nvim_create_autocmd({ "BufReadPost" }, {
        buffer = ev.buf,
        once = true,
        callback = function()
          vim.opt_local.syntax = ""
          return true
        end,
      })
    end
  end,
})

-- 5. Optimizar highlights de búsqueda
vim.api.nvim_create_autocmd("CmdlineLeave", {
  group = aug,
  callback = function()
    vim.defer_fn(function()
      vim.cmd("nohlsearch")
    end, 3000) -- Quitar highlight después de 3s
  end,
})

-- 6. Optimizar eventos de UI
vim.api.nvim_create_autocmd({ "FocusLost", "WinLeave" }, {
  group = aug,
  callback = function()
    if vim.bo.buftype == "" and vim.fn.getcmdwintype() == "" then
      vim.cmd("silent! update") -- Auto-guardar al perder foco
    end
  end,
})

-- 7. Limpiar buffers ocultos después de un tiempo
vim.api.nvim_create_autocmd("BufHidden", {
  group = aug,
  callback = function(ev)
    if vim.bo[ev.buf].buftype == "" and not vim.bo[ev.buf].modified then
      vim.defer_fn(function()
        if vim.api.nvim_buf_is_valid(ev.buf) and vim.fn.bufwinnr(ev.buf) == -1 then
          pcall(vim.api.nvim_buf_delete, ev.buf, { force = false })
        end
      end, 60000) -- 1 minuto
    end
  end,
})
