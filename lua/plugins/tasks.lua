return {
  {
    "stevearc/overseer.nvim",
    cmd = { "OverseerRun", "OverseerToggle" },
    opts = {},
    keys = {
      { "<leader>oo", "<cmd>OverseerToggle<cr>", desc = "Overseer: Toggle" },
      { "<leader>or", "<cmd>OverseerRun<cr>", desc = "Overseer: Run Task" },
    },
  },
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    event = "BufRead package.json",
    opts = {},
  },
}
