-- Refactorings avanzados para C# con Roslyn LSP
return {
  -- Rename avanzado con preview
  {
    "smjonas/inc-rename.nvim",
    cmd = "IncRename",
    keys = {
      {
        "<leader>rn",
        function()
          return ":IncRename " .. vim.fn.expand("<cword>")
        end,
        expr = true,
        desc = "Rename Symbol (Preview)",
      },
    },
    opts = {
      input_buffer_type = "dressing",
    },
  },

  -- Configuración de LSP para refactorings
  {
    "neovim/nvim-lspconfig",
    optional = true,
    opts = function()
      -- Keymaps para code actions y refactorings
      local keys = {
        {
          "<leader>ca",
          vim.lsp.buf.code_action,
          desc = "Code Action",
          mode = { "n", "v" },
          has = "codeAction",
        },
        {
          "<leader>cA",
          function()
            vim.lsp.buf.code_action({
              context = {
                only = { "source" },
                diagnostics = {},
              },
            })
          end,
          desc = "Source Action",
          has = "codeAction",
        },
        -- Refactorings específicos de C#
        {
          "<leader>re",
          function()
            vim.lsp.buf.code_action({
              context = {
                only = { "refactor.extract" },
                diagnostics = {},
              },
            })
          end,
          desc = "Extract (Method/Variable)",
          mode = { "n", "v" },
        },
        {
          "<leader>ri",
          function()
            vim.lsp.buf.code_action({
              context = {
                only = { "refactor.inline" },
                diagnostics = {},
              },
            })
          end,
          desc = "Inline Variable/Method",
        },
        {
          "<leader>rr",
          function()
            vim.lsp.buf.code_action({
              context = {
                only = { "refactor.rewrite" },
                diagnostics = {},
              },
            })
          end,
          desc = "Rewrite/Restructure Code",
          mode = { "n", "v" },
        },
        -- Quick fixes rápidos
        {
          "<leader>qf",
          function()
            vim.lsp.buf.code_action({
              apply = true, -- Aplicar automáticamente si solo hay una opción
              context = {
                only = { "quickfix" },
                diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 }),
              },
            })
          end,
          desc = "Quick Fix",
        },
        -- Organizar imports/usings
        {
          "<leader>co",
          function()
            vim.lsp.buf.code_action({
              apply = true,
              context = {
                only = { "source.organizeImports" },
                diagnostics = {},
              },
            })
          end,
          desc = "Organize Imports",
        },
        -- Remove unused usings
        {
          "<leader>cu",
          function()
            vim.lsp.buf.code_action({
              apply = true,
              context = {
                only = { "source.removeUnusedImports" },
                diagnostics = {},
              },
            })
          end,
          desc = "Remove Unused Imports",
        },
      }

      return {
        keys = keys,
      }
    end,
  },

  -- Comandos personalizados para refactorings
  {
    "nvim-lua/plenary.nvim",
    optional = true,
    config = function()
      -- Comando para extraer a método
      vim.api.nvim_create_user_command("ExtractMethod", function()
        vim.lsp.buf.code_action({
          context = {
            only = { "refactor.extract.method", "refactor.extract.function" },
            diagnostics = {},
          },
        })
      end, {
        range = true,
        desc = "Extract Method/Function",
      })

      -- Comando para extraer a variable
      vim.api.nvim_create_user_command("ExtractVariable", function()
        vim.lsp.buf.code_action({
          context = {
            only = { "refactor.extract.variable", "refactor.extract.constant" },
            diagnostics = {},
          },
        })
      end, {
        range = true,
        desc = "Extract Variable/Constant",
      })

      -- Comando para generar constructor
      vim.api.nvim_create_user_command("GenerateConstructor", function()
        vim.lsp.buf.code_action({
          context = {
            only = { "source.generateConstructor" },
            diagnostics = {},
          },
        })
      end, {
        desc = "Generate Constructor",
      })

      -- Comando para implementar interfaz
      vim.api.nvim_create_user_command("ImplementInterface", function()
        vim.lsp.buf.code_action({
          context = {
            only = { "quickfix.implement" },
            diagnostics = vim.diagnostic.get(0),
          },
        })
      end, {
        desc = "Implement Interface/Abstract Members",
      })

      -- Comando para override de métodos
      vim.api.nvim_create_user_command("OverrideMethod", function()
        vim.lsp.buf.code_action({
          context = {
            only = { "source.overrideMember" },
            diagnostics = {},
          },
        })
      end, {
        desc = "Override Method",
      })

      -- Comando para generar equals y hashcode
      vim.api.nvim_create_user_command("GenerateEquals", function()
        vim.lsp.buf.code_action({
          context = {
            only = { "source.generateEquals", "source.generateHashCode" },
            diagnostics = {},
          },
        })
      end, {
        desc = "Generate Equals and HashCode",
      })
    end,
  },
}
