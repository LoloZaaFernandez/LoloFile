return {
  -- tools
  {
    "mason.nvim",
    opts = {
      ensure_installed = {
        -- Lua
        "stylua",
        "selene",
        "luacheck",
        -- Shell
        "shellcheck",
        "shfmt",
        -- Web
        "tailwindcss-language-server",
        "typescript-language-server",
        "css-lsp",
        "prettier",
        -- Python
        "pyright",
        "black",
        "isort",
        "flake8",
        -- C#
        "omnisharp",
        "csharpier",
        "netcoredbg",
        -- Rust
        "rust-analyzer",
        "rustfmt",
      },
    },
  },
  {
    "Hoffs/omnisharp-extended-lsp.nvim",
  },

  -- lsp servers
  {
    "neovim/nvim-lspconfig",
    event = "VeryLazy", -- Carga rápida y perezosa
    opts = {
      -- Opciones globales de LSP
      inlay_hints = { enabled = true }, -- Activar inlay hints (moderno)
      codelens = { enabled = false },
      document_highlight = { enabled = true },
      -- Configuración de diagnósticos
      diagnostics = {
        underline = true,
        update_in_insert = false,
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        severity_sort = true,
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = " ",
            [vim.diagnostic.severity.WARN] = " ",
            [vim.diagnostic.severity.HINT] = " ",
            [vim.diagnostic.severity.INFO] = " ",
          },
        },
      },
      ---@type lspconfig.options
      servers = {
        cssls = {},
        tailwindcss = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
        },
        ts_ls = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern("angular.json", "package.json", ".git")(...)
          end,
          single_file_support = false,
          settings = {
            typescript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
            javascript = {
              inlayHints = {
                includeInlayParameterNameHints = "all",
                includeInlayParameterNameHintsWhenArgumentMatchesName = false,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayVariableTypeHints = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayEnumMemberValueHints = true,
              },
            },
          },
        },
        html = {},
        yamlls = {
          settings = {
            yaml = {
              keyOrdering = false,
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
              },
            },
          },
        },
        omnisharp = {
          cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
          -- Optimización máxima de velocidad
          enable_ms_build_load_projects_on_demand = true,
          enable_editorconfig_support = false, -- Desactivar para velocidad
          enable_import_completion = true,
          organize_imports_on_format = false, -- Desactivar para velocidad
          enable_roslyn_analyzers = false, -- Desactivar para velocidad
          sdk_include_prereleases = true,
          analyze_open_documents_only = true,
          -- Configuración de rendimiento
          use_modern_net = true,
          wait_for_debugger = false,
          settings = {
            RoslynExtensionsOptions = {
              -- Solo lo esencial para navegación rápida
              EnableDecompilationSupport = true,
              EnableImportCompletion = false, -- Desactivar para velocidad
              AnalyzeOpenDocumentsOnly = true,
            },
          },
        },
        lua_ls = {
          single_file_support = true,
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
      },
      setup = {
        omnisharp = function(_, opts)
          local ok, omnisharp_extended = pcall(require, "omnisharp_extended")
          if ok then
            opts.handlers = {
              ["textDocument/definition"] = omnisharp_extended.handler,
              ["textDocument/implementation"] = omnisharp_extended.handler,
              ["textDocument/typeDefinition"] = omnisharp_extended.handler,
              ["textDocument/references"] = omnisharp_extended.handler,
            }
          end
        end,
      },
    },
    keys = {
      {
        "gd",
        function()
          require("telescope.builtin").lsp_definitions({ reuse_win = false })
        end,
        desc = "Goto Definition",
      },
      {
        "gi",
        function()
          require("telescope.builtin").lsp_implementations({ reuse_win = false })
        end,
        desc = "Goto Implementation",
      },
      {
        "gy",
        function()
          require("telescope.builtin").lsp_type_definitions({ reuse_win = false })
        end,
        desc = "Goto Type Definition",
      },
      {
        "gr",
        function()
          require("telescope.builtin").lsp_references({ reuse_win = false })
        end,
        desc = "Goto References",
      },
    },
  },
}
