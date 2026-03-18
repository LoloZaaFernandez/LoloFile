-- Integración de Claude Code CLI con Neovim - Split Lateral Persistente
return {
  {
    "nvim-lua/plenary.nvim",
    lazy = false,
    config = function()
      -- Verificar si Claude Code está instalado
      local function is_claude_installed()
        local cmd = vim.fn.has("win32") == 1 and "where claude 2>nul" or "which claude 2>/dev/null"
        local handle = io.popen(cmd)
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

      -- Estado del panel de Claude
      local ClaudePanel = {
        buf = nil,
        win = nil,
        term_buf = nil,
        term_win = nil,
        term_job_id = nil,
        is_open = false,
        width = 80, -- Ancho del panel lateral
      }

      -- Función para crear el panel lateral persistente
      local function create_claude_panel()
        if ClaudePanel.is_open then
          return
        end

        -- Guardar ventana actual
        local current_win = vim.api.nvim_get_current_win()

        -- Crear split vertical a la derecha
        vim.cmd("botright vsplit")
        ClaudePanel.win = vim.api.nvim_get_current_win()

        -- Crear buffer de terminal para Claude
        ClaudePanel.term_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_win_set_buf(ClaudePanel.win, ClaudePanel.term_buf)
        vim.api.nvim_win_set_width(ClaudePanel.win, ClaudePanel.width)

        -- Configurar opciones de ventana
        vim.api.nvim_win_set_option(ClaudePanel.win, "number", false)
        vim.api.nvim_win_set_option(ClaudePanel.win, "relativenumber", false)
        vim.api.nvim_win_set_option(ClaudePanel.win, "signcolumn", "no")
        vim.api.nvim_win_set_option(ClaudePanel.win, "statuscolumn", "")
        vim.api.nvim_win_set_option(ClaudePanel.win, "winfixwidth", true) -- Ancho fijo

        -- Iniciar terminal de Claude Code
        vim.fn.termopen("claude chat", {
          on_exit = function()
            ClaudePanel.is_open = false
            ClaudePanel.term_job_id = nil
          end,
        })
        ClaudePanel.term_job_id = vim.b.terminal_job_id

        -- Configurar buffer
        vim.api.nvim_buf_set_option(ClaudePanel.term_buf, "filetype", "claude")
        vim.api.nvim_buf_set_name(ClaudePanel.term_buf, "Claude Code")

        -- Mapeos específicos para el panel de Claude
        local opts = { noremap = true, silent = true, buffer = ClaudePanel.term_buf }

        -- Ctrl+w para cerrar el panel (desde insert mode en terminal)
        vim.keymap.set("t", "<C-w>", "<C-\\><C-n>:ClaudeClose<CR>", opts)

        -- Ctrl+c para enviar interrupción a Claude
        vim.keymap.set("t", "<C-c>", "<C-c>", opts)

        -- Escapar para salir del modo terminal
        vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", opts)

        -- Enter automático en modo insert al entrar al panel
        vim.api.nvim_create_autocmd("BufEnter", {
          buffer = ClaudePanel.term_buf,
          callback = function()
            vim.cmd("startinsert")
          end,
        })

        ClaudePanel.is_open = true

        -- Restaurar ventana anterior
        vim.api.nvim_set_current_win(current_win)

        vim.notify("Claude Panel abierto - Usa <leader>cs para enviar código", vim.log.levels.INFO)
      end

      -- Función para cerrar el panel
      local function close_claude_panel()
        if not ClaudePanel.is_open then
          return
        end

        if ClaudePanel.win and vim.api.nvim_win_is_valid(ClaudePanel.win) then
          vim.api.nvim_win_close(ClaudePanel.win, true)
        end

        ClaudePanel.is_open = false
        ClaudePanel.win = nil
      end

      -- Función para toggle del panel
      local function toggle_claude_panel()
        if ClaudePanel.is_open then
          close_claude_panel()
        else
          create_claude_panel()
        end
      end

      -- Función para enviar código seleccionado a Claude
      local function send_selection_to_claude()
        if not ClaudePanel.is_open then
          create_claude_panel()
          -- Esperar un poco a que el terminal esté listo
          vim.defer_fn(function()
            send_selection_to_claude()
          end, 500)
          return
        end

        -- Obtener texto seleccionado
        local start_pos = vim.fn.getpos("'<")
        local end_pos = vim.fn.getpos("'>")
        local lines = vim.fn.getline(start_pos[2], end_pos[2])

        if #lines == 0 then
          vim.notify("No hay texto seleccionado", vim.log.levels.WARN)
          return
        end

        local selected_text = table.concat(lines, "\n")
        local filetype = vim.bo.filetype
        local filename = vim.fn.expand("%:t")

        -- Pedir prompt al usuario
        vim.ui.input({ prompt = "Pregunta a Claude: " }, function(input)
          if not input or input == "" then
            return
          end

          -- Preparar mensaje con contexto
          local message = string.format(
            "Archivo: %s (tipo: %s)\n\nCódigo:\n```%s\n%s\n```\n\nPregunta: %s\n",
            filename,
            filetype,
            filetype,
            selected_text,
            input
          )

          -- Enviar al terminal de Claude
          if ClaudePanel.term_job_id then
            -- Enviar línea por línea
            for line in message:gmatch("[^\n]+") do
              vim.fn.chansend(ClaudePanel.term_job_id, line .. "\n")
            end
            vim.fn.chansend(ClaudePanel.term_job_id, "\n") -- Enter final

            -- Enfocar el panel de Claude
            if ClaudePanel.win and vim.api.nvim_win_is_valid(ClaudePanel.win) then
              vim.api.nvim_set_current_win(ClaudePanel.win)
            end
          end
        end)
      end

      -- Función para enviar archivo completo a Claude
      local function send_file_to_claude()
        if not ClaudePanel.is_open then
          create_claude_panel()
          vim.defer_fn(function()
            send_file_to_claude()
          end, 500)
          return
        end

        local filepath = vim.fn.expand("%:p")
        local filename = vim.fn.expand("%:t")

        -- Pedir prompt al usuario
        vim.ui.input({ prompt = "¿Qué quieres hacer con este archivo? " }, function(input)
          if not input or input == "" then
            return
          end

          -- Preparar mensaje
          local message = string.format("Archivo: %s\n\nTarea: %s\n", filename, input)

          -- Enviar al terminal de Claude
          if ClaudePanel.term_job_id then
            for line in message:gmatch("[^\n]+") do
              vim.fn.chansend(ClaudePanel.term_job_id, line .. "\n")
            end
            vim.fn.chansend(ClaudePanel.term_job_id, "\n")

            -- Enfocar el panel
            if ClaudePanel.win and vim.api.nvim_win_is_valid(ClaudePanel.win) then
              vim.api.nvim_set_current_win(ClaudePanel.win)
            end
          end
        end)
      end

      -- Función para cambiar el ancho del panel
      local function resize_claude_panel(new_width)
        if ClaudePanel.win and vim.api.nvim_win_is_valid(ClaudePanel.win) then
          ClaudePanel.width = new_width
          vim.api.nvim_win_set_width(ClaudePanel.win, new_width)
        end
      end

      -- Función para enfocar el panel de Claude
      local function focus_claude_panel()
        if ClaudePanel.is_open and ClaudePanel.win and vim.api.nvim_win_is_valid(ClaudePanel.win) then
          vim.api.nvim_set_current_win(ClaudePanel.win)
          vim.cmd("startinsert")
        else
          vim.notify("El panel de Claude no está abierto", vim.log.levels.WARN)
        end
      end

      -- Comandos de usuario
      vim.api.nvim_create_user_command("ClaudeOpen", create_claude_panel, {
        desc = "Abrir panel lateral de Claude Code",
      })

      vim.api.nvim_create_user_command("ClaudeClose", close_claude_panel, {
        desc = "Cerrar panel lateral de Claude Code",
      })

      vim.api.nvim_create_user_command("ClaudeToggle", toggle_claude_panel, {
        desc = "Toggle panel lateral de Claude Code",
      })

      vim.api.nvim_create_user_command("ClaudeSend", send_selection_to_claude, {
        range = true,
        desc = "Enviar código seleccionado a Claude",
      })

      vim.api.nvim_create_user_command("ClaudeFile", send_file_to_claude, {
        desc = "Enviar archivo completo a Claude",
      })

      vim.api.nvim_create_user_command("ClaudeFocus", focus_claude_panel, {
        desc = "Enfocar panel de Claude",
      })

      vim.api.nvim_create_user_command("ClaudeResize", function(opts)
        local width = tonumber(opts.args)
        if width and width > 0 then
          resize_claude_panel(width)
        else
          vim.notify("Uso: ClaudeResize <ancho>", vim.log.levels.ERROR)
        end
      end, {
        nargs = 1,
        desc = "Cambiar ancho del panel de Claude",
      })

      -- Atajos de teclado
      vim.keymap.set("n", "<leader>co", create_claude_panel, { desc = "Abrir Claude Panel" })
      vim.keymap.set("n", "<leader>ct", toggle_claude_panel, { desc = "Toggle Claude Panel" })
      vim.keymap.set("n", "<leader>cc", close_claude_panel, { desc = "Cerrar Claude Panel" })
      vim.keymap.set("v", "<leader>cs", send_selection_to_claude, { desc = "Enviar selección a Claude" })
      vim.keymap.set("n", "<leader>cf", send_file_to_claude, { desc = "Enviar archivo a Claude" })
      vim.keymap.set("n", "<leader>cF", focus_claude_panel, { desc = "Enfocar Claude Panel" })

      -- Atajos rápidos adicionales
      vim.keymap.set("n", "<leader>cw", function()
        resize_claude_panel(100)
      end, { desc = "Claude Panel Wide" })
      vim.keymap.set("n", "<leader>cn", function()
        resize_claude_panel(60)
      end, { desc = "Claude Panel Narrow" })

      -- Auto-comandos para persistencia
      vim.api.nvim_create_autocmd("VimResized", {
        callback = function()
          -- Mantener el ancho del panel cuando se redimensiona Neovim
          if ClaudePanel.is_open and ClaudePanel.win and vim.api.nvim_win_is_valid(ClaudePanel.win) then
            vim.api.nvim_win_set_width(ClaudePanel.win, ClaudePanel.width)
          end
        end,
      })

      vim.notify("Claude Code Panel integrado ✓ (Use <leader>co para abrir)", vim.log.levels.INFO)
    end,
  },
}
