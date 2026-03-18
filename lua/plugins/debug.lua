-- Debugging avanzado para .NET Core con UI mejorada
return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "nvim-neotest/nvim-nio",
      {
        "rcarriga/nvim-dap-ui",
        opts = {
          -- Layout mejorado tipo Visual Studio
          layouts = {
            {
              elements = {
                { id = "scopes", size = 0.33 }, -- Variables locales y this
                { id = "breakpoints", size = 0.17 }, -- Breakpoints
                { id = "stacks", size = 0.25 }, -- Call stack
                { id = "watches", size = 0.25 }, -- Watches personalizados
              },
              size = 0.33,
              position = "right", -- Panel derecho
            },
            {
              elements = {
                { id = "repl", size = 0.5 }, -- REPL para evaluar expresiones
                { id = "console", size = 0.5 }, -- Output de la aplicación
              },
              size = 0.27,
              position = "bottom", -- Panel inferior
            },
          },
          controls = {
            enabled = true,
            element = "repl",
            icons = {
              pause = "",
              play = "",
              step_into = "",
              step_over = "",
              step_out = "",
              step_back = "",
              run_last = "",
              terminate = "",
              disconnect = "",
            },
          },
          floating = {
            max_height = 0.9,
            max_width = 0.5,
            border = "rounded",
            mappings = {
              close = { "q", "<Esc>" },
            },
          },
          render = {
            max_type_length = nil, -- Mostrar tipo completo
            max_value_lines = 100, -- Mostrar más líneas en valores
            indent = 1,
          },
        },
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {
          enabled = true,
          enabled_commands = true,
          highlight_changed_variables = true,
          highlight_new_as_changed = true,
          show_stop_reason = true,
          commented = false, -- No usar formato de comentario
          only_first_definition = false,
          all_references = true,
          filter_references_pattern = "<module", -- Filtrar referencias internas
          virt_text_pos = "eol", -- Al final de la línea
          all_frames = false,
          virt_lines = false,
          virt_text_win_col = nil,
        },
      },
    },
    keys = {
      -- Controles de debugging
      {
        "<F5>",
        function()
          require("dap").continue()
        end,
        desc = "Debug: Start/Continue",
      },
      {
        "<F10>",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: Step Over",
      },
      {
        "<F11>",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: Step Into",
      },
      {
        "<S-F11>",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: Step Out",
      },
      {
        "<F9>",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: Toggle Breakpoint",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Debug: Conditional Breakpoint",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug: Toggle Breakpoint",
      },
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Debug: Continue",
      },
      {
        "<leader>dC",
        function()
          require("dap").run_to_cursor()
        end,
        desc = "Debug: Run to Cursor",
      },
      {
        "<leader>dg",
        function()
          require("dap").goto_()
        end,
        desc = "Debug: Go to Line (no execute)",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Debug: Step Into",
      },
      {
        "<leader>dj",
        function()
          require("dap").down()
        end,
        desc = "Debug: Down in Call Stack",
      },
      {
        "<leader>dk",
        function()
          require("dap").up()
        end,
        desc = "Debug: Up in Call Stack",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Debug: Run Last",
      },
      {
        "<leader>do",
        function()
          require("dap").step_out()
        end,
        desc = "Debug: Step Out",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_over()
        end,
        desc = "Debug: Step Over",
      },
      {
        "<leader>dp",
        function()
          require("dap").pause()
        end,
        desc = "Debug: Pause",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Debug: Toggle REPL",
      },
      {
        "<leader>ds",
        function()
          require("dap").session()
        end,
        desc = "Debug: Session",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Debug: Terminate",
      },
      {
        "<leader>dw",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Debug: Widgets",
      },
      -- DAP UI
      {
        "<leader>du",
        function()
          require("dapui").toggle()
        end,
        desc = "Debug: Toggle UI",
      },
      {
        "<leader>de",
        function()
          require("dapui").eval()
        end,
        desc = "Debug: Eval Expression",
        mode = { "n", "v" },
      },
    },
    config = function()
      local dap = require("dap")

      -- Configuración del adapter para .NET Core
      dap.adapters.coreclr = {
        type = "executable",
        command = "netcoredbg",
        args = { "--interpreter=vscode" },
      }

      -- Función auxiliar para encontrar DLL automáticamente
      local function find_dll()
        local cwd = vim.fn.getcwd()
        -- Buscar en bin/Debug/net*.0/*.dll
        local patterns = {
          "/bin/Debug/net8.0/*.dll",
          "/bin/Debug/net7.0/*.dll",
          "/bin/Debug/net6.0/*.dll",
          "/bin/Release/net8.0/*.dll",
          "/bin/Release/net7.0/*.dll",
          "/bin/Release/net6.0/*.dll",
        }

        for _, pattern in ipairs(patterns) do
          local files = vim.fn.glob(cwd .. pattern, false, true)
          if #files > 0 then
            -- Retornar el primero que no sea deps.dll o runtimeconfig.json
            for _, file in ipairs(files) do
              if not file:match("deps%.dll$") and not file:match("%.pdb$") then
                return file
              end
            end
          end
        end

        -- Si no encuentra, preguntar al usuario
        return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/net8.0/", "file")
      end

      -- Configuraciones de debugging para C#
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "Launch .NET (Auto-detect DLL)",
          request = "launch",
          program = find_dll,
        },
        {
          type = "coreclr",
          name = "Launch .NET (Manual DLL)",
          request = "launch",
          program = function()
            return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/bin/Debug/net8.0/", "file")
          end,
        },
        {
          type = "coreclr",
          name = "Attach to Process",
          request = "attach",
          processId = function()
            return require("dap.utils").pick_process()
          end,
        },
        {
          type = "coreclr",
          name = "Launch ASP.NET Core",
          request = "launch",
          program = find_dll,
          env = {
            ASPNETCORE_ENVIRONMENT = "Development",
            ASPNETCORE_URLS = "http://localhost:5000",
          },
          cwd = "${workspaceFolder}",
        },
      }

      -- Iconos para signos de debugging
      vim.fn.sign_define("DapBreakpoint", {
        text = "",
        texthl = "DiagnosticSignError",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointCondition", {
        text = "",
        texthl = "DiagnosticSignWarn",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapBreakpointRejected", {
        text = "",
        texthl = "DiagnosticSignHint",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapLogPoint", {
        text = "",
        texthl = "DiagnosticSignInfo",
        linehl = "",
        numhl = "",
      })
      vim.fn.sign_define("DapStopped", {
        text = "",
        texthl = "DiagnosticSignWarn",
        linehl = "Visual",
        numhl = "DiagnosticSignWarn",
      })

      -- Auto abrir/cerrar DAP UI
      local dapui = require("dapui")
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      -- Resaltar línea actual al debuggear
      vim.api.nvim_set_hl(0, "DapStoppedLine", { default = true, link = "Visual" })
    end,
  },
}
