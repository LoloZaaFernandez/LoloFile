return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs = { "csharpier" },
        typescript = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        json = { "prettier" },
      },
      -- Formatear solo las líneas modificadas (MEJORA DE RENDIMIENTO en proyectos grandes)
      format_on_save = function(bufnr)
        -- Deshabilitar formateo automático con timeout_ms = 0
        -- Usar el mapeo manual <leader>cf para formatear cuando lo necesites
        return {
          timeout_ms = 500,
          lsp_fallback = true,
          -- Formatear solo el rango modificado
          range = nil, -- Se configura por los autocomandos
        }
      end,
    },
  },
}
