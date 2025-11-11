-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- Turn off paste mode when leaving insert
vim.api.nvim_create_autocmd("InsertLeave", {
  pattern = "*",
  command = "set nopaste",
})

-- Disable the concealing in some file formats
-- The default conceallevel is 3 in LazyVim
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "json", "jsonc", "markdown" },
  callback = function()
    vim.opt.conceallevel = 0
  end,
})
-- FORMATEO INTELIGENTE: Solo formatea líneas modificadas en proyectos grandes
-- Para proyectos pequeños o cuando quieras formatear todo, usa: <leader>cF
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.py", "*.cs", "*.ts", "*.tsx", "*.js", "*.jsx" },
  callback = function(args)
    -- Intentar obtener cambios de git para formatear solo lo modificado
    local bufnr = args.buf
    local filename = vim.api.nvim_buf_get_name(bufnr)

    -- Verificar si el archivo está en un repo git
    local git_root = vim.fn.systemlist("git -C " .. vim.fn.shellescape(vim.fn.fnamemodify(filename, ":h")) .. " rev-parse --show-toplevel 2>nul")[1]

    if git_root and git_root ~= "" then
      -- Obtener las líneas modificadas usando git diff
      local diff_output = vim.fn.systemlist(
        "git -C " .. vim.fn.shellescape(git_root) .. " diff -U0 --no-color --no-ext-diff " .. vim.fn.shellescape(filename) .. " 2>nul"
      )

      if vim.v.shell_error == 0 and #diff_output > 0 then
        -- Parsear el output de git diff para obtener rangos modificados
        local ranges = {}
        for _, line in ipairs(diff_output) do
          local start_line, line_count = line:match("^@@.*%+(%d+),?(%d*)")
          if start_line then
            start_line = tonumber(start_line)
            line_count = tonumber(line_count) or 1
            if line_count > 0 then
              table.insert(ranges, { start = { start_line, 0 }, ["end"] = { start_line + line_count - 1, 0 } })
            end
          end
        end

        -- Formatear solo los rangos modificados
        if #ranges > 0 then
          require("conform").format({
            bufnr = bufnr,
            async = false,
            lsp_fallback = true,
            range = ranges[1], -- Formatear el primer rango (puedes iterar todos si quieres)
          })
          return
        end
      end
    end

    -- Fallback: Si no hay cambios de git o es un archivo nuevo, NO formatear automáticamente
    -- El usuario puede formatear manualmente con <leader>cf (solo buffer) o <leader>cF (todo el proyecto)
  end,
})
