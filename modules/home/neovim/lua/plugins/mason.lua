-- mason-tool-installer – automatically install/update Mason packages.
-- See https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
return {
  "WhoIsSethDaniel/mason-tool-installer.nvim",
  opts = {
    ensure_installed = {
      "codebook",
      "nixfmt",
      "oxfmt",
      "oxlint",
      "typescript-language-server", -- ts_ls
    },
  },
}
