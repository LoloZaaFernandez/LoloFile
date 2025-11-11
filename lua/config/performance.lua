-- Configuraciones adicionales de rendimiento para LoloVim
-- Este archivo contiene optimizaciones para mejorar la velocidad de inicio y respuesta

-- 1. Reducir tiempo de espera para comandos mapeados
vim.opt.timeoutlen = 300 -- Por defecto es 1000ms, reducir a 300ms

-- 2. Optimizar updatetime para mejor respuesta (CursorHold, swap file writing)
vim.opt.updatetime = 200 -- Por defecto es 4000ms

-- 3. Reducir redraw durante macros
vim.opt.lazyredraw = true

-- 4. Optimizar memoria y swap
vim.opt.swapfile = false -- Deshabilitar swap files para mejor rendimiento
vim.opt.undofile = true -- Mantener historial de deshacer en archivo
vim.opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- 5. Optimizar búsqueda
vim.opt.synmaxcol = 240 -- Limitar resaltado de sintaxis a 240 columnas (útil en líneas largas)

-- 6. Mejor manejo de archivos grandes
vim.api.nvim_create_autocmd("BufReadPre", {
  pattern = "*",
  callback = function()
    local file_size = vim.fn.getfsize(vim.fn.expand("<afile>"))
    -- Si el archivo es mayor a 1MB (1048576 bytes), deshabilitar algunas funciones
    if file_size > 1048576 then
      vim.cmd("syntax off") -- Deshabilitar sintaxis
      vim.opt_local.foldmethod = "manual" -- Deshabilitar folding automático
      vim.opt_local.undolevels = -1 -- Deshabilitar undo
      vim.notify("Archivo grande detectado. Algunas funciones deshabilitadas para mejor rendimiento.", vim.log.levels.WARN)
    end
  end,
})

-- 7. Optimizar LSP para proyectos grandes
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.handlers["textDocument/publishDiagnostics"], {
  -- Deshabilitar virtual text para diagnósticos (puede ser lento en archivos grandes)
  virtual_text = false,
  -- Mostrar diagnósticos solo en modo normal
  update_in_insert = false,
  -- Retrasar actualización de diagnósticos
  severity_sort = true,
})

-- 8. Configurar debounce para autocomandos costosos
local augroup = vim.api.nvim_create_augroup("PerformanceOptimizations", { clear = true })

-- Retrasar resaltado de búsqueda durante scrolling rápido
vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
  group = augroup,
  callback = function()
    if vim.fn.mode() == "n" then
      vim.opt.hlsearch = true
    end
  end,
})

print("⚡ Optimizaciones de rendimiento cargadas")
