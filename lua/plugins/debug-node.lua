-- Debugging para Node.js/JavaScript/TypeScript vía vscode-js-debug
-- js-debug-adapter se instala vía mason (ver ensure_installed en lsp.lua)
return {
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = { "mfussenegger/nvim-dap" },
    ft = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
    config = function()
      require("dap-vscode-js").setup({
        debugger_path = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter",
        adapters = { "pwa-node" },
      })

      local dap = require("dap")
      for _, language in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Launch File",
            program = "${file}",
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Attach to Process",
            processId = require("dap.utils").pick_process,
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Debug npm start",
            runtimeExecutable = "npm",
            runtimeArgs = { "run", "start" },
            cwd = "${workspaceFolder}",
            console = "integratedTerminal",
          },
        }
      end
    end,
  },
}
