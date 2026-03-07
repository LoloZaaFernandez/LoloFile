-- Navegación avanzada para arquitecturas C# multi-capa
-- Comandos para navegar rápidamente entre Controllers, Services, Repositories, DTOs

return {
  {
    "nvim-telescope/telescope.nvim",
    optional = true,
    keys = {
      -- Navegación por capas de arquitectura C#
      {
        "<leader>nC",
        function()
          require("telescope.builtin").find_files({
            prompt_title = "Find Controllers",
            search_dirs = { vim.fn.getcwd() },
            file_ignore_patterns = { "bin/", "obj/", "node_modules/" },
            find_command = { "rg", "--files", "--glob", "*Controller.cs" },
          })
        end,
        desc = "Find Controllers",
      },
      {
        "<leader>nS",
        function()
          require("telescope.builtin").find_files({
            prompt_title = "Find Services",
            search_dirs = { vim.fn.getcwd() },
            file_ignore_patterns = { "bin/", "obj/", "node_modules/" },
            find_command = { "rg", "--files", "--glob", "*Service.cs" },
          })
        end,
        desc = "Find Services",
      },
      {
        "<leader>nR",
        function()
          require("telescope.builtin").find_files({
            prompt_title = "Find Repositories",
            search_dirs = { vim.fn.getcwd() },
            file_ignore_patterns = { "bin/", "obj/", "node_modules/" },
            find_command = { "rg", "--files", "--glob", "*Repository.cs" },
          })
        end,
        desc = "Find Repositories",
      },
      {
        "<leader>nD",
        function()
          require("telescope.builtin").find_files({
            prompt_title = "Find DTOs/Models",
            search_dirs = { vim.fn.getcwd() },
            file_ignore_patterns = { "bin/", "obj/", "node_modules/" },
            find_command = {
              "rg",
              "--files",
              "--glob",
              "*Dto.cs",
              "--glob",
              "*DTO.cs",
              "--glob",
              "*Model.cs",
              "--glob",
              "*Request.cs",
              "--glob",
              "*Response.cs",
            },
          })
        end,
        desc = "Find DTOs/Models",
      },
      {
        "<leader>nI",
        function()
          require("telescope.builtin").find_files({
            prompt_title = "Find Interfaces",
            search_dirs = { vim.fn.getcwd() },
            file_ignore_patterns = { "bin/", "obj/", "node_modules/" },
            find_command = { "rg", "--files", "--glob", "I*.cs" },
          })
        end,
        desc = "Find Interfaces",
      },
      -- Búsqueda inteligente de implementación relacionada
      {
        "<leader>ni",
        function()
          -- Obtener el nombre del archivo actual sin extensión
          local current_file = vim.fn.expand("%:t:r")
          local search_term = ""

          -- Si estamos en un Controller, buscar el Service correspondiente
          if current_file:match("Controller$") then
            search_term = current_file:gsub("Controller$", "Service")
          -- Si estamos en un Service, buscar el Repository correspondiente
          elseif current_file:match("Service$") then
            search_term = current_file:gsub("Service$", "Repository")
          -- Si estamos en un Repository, buscar la entidad/modelo
          elseif current_file:match("Repository$") then
            search_term = current_file:gsub("Repository$", "")
          -- Si estamos en una interfaz, buscar la implementación
          elseif current_file:match("^I") then
            search_term = current_file:gsub("^I", "")
          else
            -- Búsqueda genérica
            search_term = current_file
          end

          require("telescope.builtin").find_files({
            prompt_title = "Find Related: " .. search_term,
            search_dirs = { vim.fn.getcwd() },
            file_ignore_patterns = { "bin/", "obj/", "node_modules/" },
            default_text = search_term,
          })
        end,
        desc = "Find Related Implementation",
      },
      -- Buscar por símbolo en todo el workspace (métodos, clases, etc)
      {
        "<leader>ns",
        function()
          require("telescope.builtin").lsp_dynamic_workspace_symbols({
            prompt_title = "Find Symbols in Workspace",
            fname_width = 50,
          })
        end,
        desc = "Find Workspace Symbols",
      },
      -- Buscar referencias en todo el proyecto
      {
        "<leader>nf",
        function()
          require("telescope.builtin").lsp_references({
            prompt_title = "Find All References",
            include_declaration = false,
            fname_width = 50,
          })
        end,
        desc = "Find All References",
      },
    },
  },
  -- Configuración adicional para mejorar la navegación
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = function(_, opts)
      -- Agregar auto-comando para mostrar breadcrumbs de navegación
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("csharp_navigation", { clear = true }),
        callback = function(ev)
          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          -- Funciona con csharp_ls u omnisharp
          if client and (client.name == "csharp_ls" or client.name == "omnisharp") then
            -- Activar inlay hints automáticamente para C#
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
            end
          end
        end,
      })
    end,
  },
}
