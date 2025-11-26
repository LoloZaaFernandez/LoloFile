return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "LazyFile", "VeryLazy" },
    lazy = vim.fn.argc(-1) == 0, -- cargar si no hay archivos
    init = function(plugin)
      -- Cargar treesitter antes de VeryLazy para mejor highlighting
      require("lazy.core.loader").add_to_rtp(plugin)
    end,
    cmd = { "TSUpdateSync", "TSUpdate", "TSInstall" },
    keys = {
      { "<c-space>", desc = "Increment Selection" },
      { "<bs>", desc = "Decrement Selection", mode = "x" },
    },
    opts = {
      ensure_installed = {
        "bash",
        "c",
        "c_sharp",
        "cpp",
        "css",
        "diff",
        "go",
        "graphql",
        "html",
        "http",
        "java",
        "javascript",
        "jsdoc",
        "json",
        "jsonc",
        "lua",
        "luadoc",
        "luap",
        "markdown",
        "markdown_inline",
        "python",
        "query",
        "regex",
        "rust",
        "scss",
        "sql",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        "xml",
        "yaml",
      },
      -- Instalar parsers de forma incremental
      auto_install = true,
      sync_install = false,
      highlight = {
        enable = true,
        additional_vim_regex_highlighting = false,
      },
      indent = {
        enable = true,
        disable = { "python", "yaml" },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      textobjects = {
        move = {
          enable = true,
          goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
          goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
          goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
          goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)

      -- MDX
      vim.filetype.add({
        extension = {
          mdx = "mdx",
        },
      })
      vim.treesitter.language.register("markdown", "mdx")
    end,
  },
  -- Textobjects para treesitter
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    event = "VeryLazy",
    enabled = true,
    config = function()
      -- Al cargar nvim-treesitter-textobjects
      if require("lazy.core.config").spec.plugins["nvim-treesitter"] then
        local opts = require("lazy.core.plugin").values(
          require("lazy.core.config").spec.plugins["nvim-treesitter"],
          "opts",
          false
        )
        if type(opts.textobjects) == "table" then
          require("nvim-treesitter").setup({ textobjects = opts.textobjects })
        end
      end
    end,
  },
}
