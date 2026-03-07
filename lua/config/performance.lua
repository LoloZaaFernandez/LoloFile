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

-- 8. Optimizaciones para proyectos .NET muy grandes (30+ proyectos)
-- Limitar memoria de LSP
vim.g.lsp_max_memory = 4096 -- MB

-- Desactivar diagnósticos en archivos muy grandes
vim.api.nvim_create_autocmd("BufReadPost", {
  group = aug,
  pattern = "*.cs",
  callback = function(ev)
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
    if ok and stats and stats.size > 500000 then -- 500KB
      -- Archivo C# muy grande, reducir features
      vim.diagnostic.disable(ev.buf)
      vim.notify("Diagnósticos desactivados para archivo grande: " .. vim.fn.expand("%:t"), vim.log.levels.INFO)
    end
  end,
})

-- Limitar número de diagnósticos mostrados simultáneamente
vim.diagnostic.config({
  virtual_text = {
    spacing = 4,
    prefix = "●",
    severity = { min = vim.diagnostic.severity.WARN }, -- Solo warnings y errores
  },
  signs = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
  underline = {
    severity = { min = vim.diagnostic.severity.WARN },
  },
  update_in_insert = false, -- No actualizar en insert mode (importante para rendimiento)
  severity_sort = true,
})

-- 9. Optimizar LSP debounce para proyectos grandes
vim.opt.updatetime = 300 -- Aumentar de 200 a 300ms para proyectos grandes

-- 10. Optimizar swap y backup para SSDs
vim.opt.swapfile = false -- Deshabilitar swap en SSDs modernos
vim.opt.backup = false -- No crear backups temporales
vim.opt.writebackup = false -- No crear backup antes de escribir

-- 11. Mejorar rendimiento de treesitter en archivos C# grandes
vim.api.nvim_create_autocmd("FileType", {
  group = aug,
  pattern = "cs",
  callback = function()
    -- Limitar highlighting para archivos C# muy grandes
    if vim.fn.line("$") > 5000 then
      vim.treesitter.stop() -- Deshabilitar treesitter en archivos > 5000 líneas
      vim.notify("Treesitter desactivado para archivo grande", vim.log.levels.INFO)
    end
  end,
})

-- 12. Reducir historial para ahorrar memoria
vim.opt.history = 1000 -- Reducir de default (10000)

-- 13. Optimizar wildmenu
vim.opt.wildmode = "longest:full,full"
vim.opt.wildignore:append({
  "*/bin/*",
  "*/obj/*",
  "*/node_modules/*",
  "*/.git/*",
  "*.dll",
  "*.exe",
  "*.pdb",
  "*.cache",
})

-- 14. Configurar timeoutlen para mejor experiencia
vim.opt.timeoutlen = 300 -- Reducir timeout para teclas (mejor UX)
vim.opt.ttimeoutlen = 10 -- Timeout más rápido para escape

-- 15. Desactivar matchparen en archivos muy grandes
vim.api.nvim_create_autocmd("BufEnter", {
  group = aug,
  callback = function()
    if vim.fn.line("$") > 10000 then
      vim.cmd("NoMatchParen") -- Deshabilitar resaltado de paréntesis
    end
  end,
})

-- 16. Limitar ancho de mensajes
vim.opt.cmdheight = 0 -- Ocultar cmdline cuando no se usa (más espacio)

-- 17. Optimizar redrawtime
vim.opt.redrawtime = 1500 -- Reducir tiempo máximo de redraw

-- 18. Configurar scrolloff para mejor experiencia
vim.opt.scrolloff = 8 -- Mantener 8 líneas visibles arriba/abajo del cursor
vim.opt.sidescrolloff = 8

-- 19. Monitoreo de rendimiento (opcional, comentar en producción)
-- vim.api.nvim_create_autocmd("VimEnter", {
--   callback = function()
--     local startuptime = vim.fn.reltime(vim.g.start_time)
--     local ms = vim.fn.reltimefloat(startuptime) * 1000
--     vim.notify(string.format("Neovim iniciado en %.2f ms", ms), vim.log.levels.INFO)
--   end,
-- })

-- Mensaje de confirmación
vim.notify("Optimizaciones de rendimiento cargadas para proyectos grandes", vim.log.levels.INFO)
