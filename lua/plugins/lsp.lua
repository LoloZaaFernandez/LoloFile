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
        -- C# (csharp-language-server es más ligero para proyectos grandes)
        "csharp-language-server",
        "omnisharp", -- Backup por si csharp-language-server no funciona bien
        "csharpier",
        "netcoredbg",
        -- Rust
        "rust-analyzer",
        "rustfmt",
      },
    },
  },
  -- lsp servers
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" }, -- Cargar solo al abrir archivos, no en startup
    opts = {
      -- Retrasar diagnósticos para mejor rendimiento
      diagnostics = {
        update_in_insert = false,
        debounce = 300, -- Esperar 300ms antes de mostrar diagnósticos
      },
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
        -- csharp_ls: Servidor C# ligero y rápido (principal)
        csharp_ls = {
          -- Configuración optimizada para proyectos grandes
          filetypes = { "cs" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            -- Buscar .sln primero para proyectos multi-proyecto
            return util.root_pattern("*.sln")(fname)
              or util.root_pattern("*.csproj")(fname)
              or util.find_git_ancestor(fname)
          end,
          handlers = {
            ["textDocument/definition"] = function(...)
              return vim.lsp.handlers["textDocument/definition"](...)
            end,
          },
          on_attach = function(client, bufnr)
            -- Habilitar inlay hints si está disponible
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
          end,
        },
        -- OmniSharp: Backup optimizado (si csharp_ls no funciona bien)
        omnisharp = {
          cmd = { "omnisharp", "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },
          -- Optimización máxima para proyectos 30+
          enable_ms_build_load_projects_on_demand = true,
          enable_editorconfig_support = false, -- Desactivar para velocidad
          enable_import_completion = true,
          organize_imports_on_format = false,
          enable_roslyn_analyzers = false, -- Desactivar analizadores pesados
          sdk_include_prereleases = true,
          analyze_open_documents_only = true, -- CRÍTICO para proyectos grandes
          use_modern_net = true,
          filetypes = { "cs" },
          root_dir = function(fname)
            local util = require("lspconfig.util")
            return util.root_pattern("*.sln")(fname)
              or util.root_pattern("*.csproj")(fname)
              or util.find_git_ancestor(fname)
          end,
          on_attach = function(client, bufnr)
            -- Deshabilitar omnisharp si csharp_ls ya está activo
            local clients = vim.lsp.get_clients({ bufnr = bufnr })
            for _, c in ipairs(clients) do
              if c.name == "csharp_ls" and c.id ~= client.id then
                vim.notify("csharp_ls ya activo, deteniendo omnisharp", vim.log.levels.INFO)
                vim.lsp.stop_client(client.id)
                return
              end
            end

            -- Habilitar inlay hints
            if client.server_capabilities.inlayHintProvider then
              vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
            end
          end,
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
        csharp_ls = function(_, opts)
          -- csharp_ls es un servidor ligero, no necesita configuración especial
        end,
        omnisharp = function(_, opts)
          -- OmniSharp backup con configuración optimizada ya definida arriba
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
