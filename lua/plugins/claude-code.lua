-- Integración de Claude Code CLI con Neovim
return {
  {
    "3rd/image.nvim",
    optional = true,
  },
  {
    -- Este es solo un wrapper de configuración, no un plugin externo
    "nvim-lua/plenary.nvim",
    lazy = false,
    config = function()
      -- Verificar si Claude Code está instalado
      local function is_claude_installed()
        local handle = io.popen("where claude 2>nul")
        if handle then
          local result = handle:read("*a")
          handle:close()
          return result ~= ""
        end
        return false
      end

      if not is_claude_installed() then
        vim.notify("Claude Code CLI no está instalado o no está en PATH", vim.log.levels.WARN)
        return
      end

      -- Buffer para el chat de Claude
      local claude_buf = nil
      local claude_win = nil

      -- Función para abrir ventana de chat
      local function open_claude_chat()
        -- Si ya existe, enfocarlo
        if claude_win and vim.api.nvim_win_is_valid(claude_win) then
          vim.api.nvim_set_current_win(claude_win)
          return
        end

        -- Crear nuevo buffer si no existe
        if not claude_buf or not vim.api.nvim_buf_is_valid(claude_buf) then
          claude_buf = vim.api.nvim_create_buf(false, true)
          vim.api.nvim_buf_set_option(claude_buf, "buftype", "nofile")
          vim.api.nvim_buf_set_option(claude_buf, "filetype", "markdown")
          vim.api.nvim_buf_set_name(claude_buf, "Claude Code Chat")
        end

        -- Crear split vertical a la derecha
        vim.cmd("vsplit")
        claude_win = vim.api.nvim_get_current_win()
        vim.api.nvim_win_set_buf(claude_win, claude_buf)
        vim.api.nvim_win_set_width(claude_win, 60)

        -- Mapeos en el buffer de chat
        local opts = { noremap = true, silent = true, buffer = claude_buf }
        vim.keymap.set("n", "q", function()
          vim.api.nvim_win_close(claude_win, true)
        end, opts)
      end

      -- Función para cerrar el chat
      local function close_claude_chat()
        if claude_win and vim.api.nvim_win_is_valid(claude_win) then
          vim.api.nvim_win_close(claude_win, true)
          claude_win = nil
        end
      end

      -- Función para toggle del chat
      local function toggle_claude_chat()
        if claude_win and vim.api.nvim_win_is_valid(claude_win) then
          close_claude_chat()
        else
          open_claude_chat()
        end
      end

      -- Función para preguntar a Claude sobre código seleccionado
      local function ask_claude_about_selection()
        -- Obtener texto seleccionado
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        local lines = vim.fn.getline(start_pos[2], end_pos[2])

        if #lines == 0 then
          vim.notify("No hay texto seleccionado", vim.log.levels.WARN)
          return
        end

        local selected_text = table.concat(lines, "\n")

        -- Pedir prompt al usuario
        vim.ui.input({ prompt = "Pregunta a Claude: " }, function(input)
          if not input or input == "" then
            return
          end

          -- Abrir chat si no está abierto
          if not claude_win or not vim.api.nvim_win_is_valid(claude_win) then
            open_claude_chat()
          end

          -- Agregar contexto y pregunta al buffer
          local content = {
            "## Tu código:",
            "```" .. vim.bo.filetype,
            selected_text,
            "```",
            "",
            "## Tu pregunta:",
            input,
            "",
            "## Nota:",
            "Usa el comando :ClaudeChat para abrir terminal interactiva con Claude",
            "",
          }

          vim.api.nvim_buf_set_lines(claude_buf, 0, -1, false, content)
        end)
      end

      -- Función para abrir terminal con Claude Code
      local function open_claude_terminal()
        vim.cmd("vsplit")
        vim.cmd("terminal claude chat")
        vim.cmd("startinsert")
      end

      -- Comandos de usuario
      vim.api.nvim_create_user_command("ClaudeChat", open_claude_terminal, {
        desc = "Abrir terminal con Claude Code chat",
      })

      vim.api.nvim_create_user_command("ClaudeToggle", toggle_claude_chat, {
        desc = "Toggle ventana de Claude Code",
      })

      vim.api.nvim_create_user_command("ClaudeAsk", ask_claude_about_selection, {
        range = true,
        desc = "Preguntar a Claude sobre código seleccionado",
      })

      -- Atajos de teclado
      vim.keymap.set("n", "<leader>cc", open_claude_terminal, { desc = "Claude Chat Terminal" })
      vim.keymap.set("n", "<leader>ct", toggle_claude_chat, { desc = "Toggle Claude Window" })
      vim.keymap.set("v", "<leader>ca", ask_claude_about_selection, { desc = "Ask Claude" })

      vim.notify("Claude Code integración cargada ✓", vim.log.levels.INFO)
    end,
  },
}
