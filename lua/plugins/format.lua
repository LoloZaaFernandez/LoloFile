return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        -- Web
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        -- Python
        python = { "ruff_organize_imports", "ruff_fix", "ruff_format" },
        -- Rust
        rust = { "rustfmt" },
        -- Lua
        lua = { "stylua" },
        -- Shell
        sh = { "shfmt" },
        bash = { "shfmt" },
      },
      -- Deshabilitar formateo automático - solo manual con <leader>cf
      format_on_save = nil,
      format_after_save = nil,
      -- Notificaciones de formateo
      notify_on_error = true,
      notify_no_formatters = false,
    },
  },
}
