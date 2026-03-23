-- mason-tool-installer – automatically install/update Mason packages.
-- See https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  opts = {
    ensure_installed = {
      "codebook",
      "eslint-lsp",
      "nixfmt",
      "oxfmt",
      "oxlint",
      "prettier",
      "typescript-language-server", -- ts_ls
    },
  },
}
