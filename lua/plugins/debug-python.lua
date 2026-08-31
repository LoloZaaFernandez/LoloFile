-- Debugging para Python (debugpy vía nvim-dap-python)
return {
  {
    "mfussenegger/nvim-dap-python",
    ft = "python",
    dependencies = {
      "mfussenegger/nvim-dap",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      -- debugpy lo instala y gestiona mason-nvim-dap, path estándar de mason
      local debugpy_path = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/Scripts/python.exe"
      require("dap-python").setup(debugpy_path)
    end,
    keys = {
      -- Continue/step/toggle breakpoint ya están definidos globalmente en debug.lua
      -- (nvim-dap es agnóstico al lenguaje, esos mapeos ya funcionan con Python)
      {
        "<leader>dpr",
        function()
          require("dap-python").test_method()
        end,
        desc = "Debug: Run Python Test Method",
        ft = "python",
      },
      {
        "<leader>dpc",
        function()
          require("dap-python").test_class()
        end,
        desc = "Debug: Run Python Test Class",
        ft = "python",
      },
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = "mason.nvim",
    opts = {
      ensure_installed = { "debugpy" },
      automatic_installation = true,
    },
  },
}
