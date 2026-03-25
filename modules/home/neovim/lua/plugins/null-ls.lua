return {
  -- Register nixfmt directly with none-ls (no Mason needed)
  {
    "nvimtools/none-ls.nvim",
    opts = function(_, opts)
      local null_ls = require("null-ls")
      opts.sources = opts.sources or {}
      table.insert(opts.sources, null_ls.builtins.formatting.nixfmt)
    end,
  },
  -- Tell mason-null-ls not to auto-install nixfmt
  {
    "jay-babu/mason-null-ls.nvim",
    opts = {
      ignore_install = { "nixfmt" },
    },
  },
}
