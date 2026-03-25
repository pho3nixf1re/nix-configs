-- AstroLSP configuration – LSP server setup.
-- See https://docs.astronvim.com/recipes/advanced_lsp/
return {
  "AstroNvim/astrolsp",
  ---@param opts AstroLSPOpts
  opts = function(plugin, opts)
    opts.servers = opts.servers or {}
    table.insert(opts.servers, "codebook")
    table.insert(opts.servers, "eslint")

    opts.config = require("astrocore").extend_tbl(opts.config or {}, {
      codebook = {
        cmd = { "codebook-lsp", "serve" },
        filetypes = { "*" },
        root_dir = require("lspconfig.util").root_pattern(
          "codebook.toml", ".codebook.toml", ".git"
        ),
        on_attach = function(client, _)
          local ns = vim.lsp.diagnostic.get_namespace(client.id)
          vim.diagnostic.config({ virtual_text = false, signs = false }, ns)
        end,
      },
      ts_ls = {
        filetypes = {
          "javascript", "javascriptreact", "javascript.jsx",
          "typescript", "typescriptreact", "typescript.tsx",
        },
      },
      oxc_language_server = {
        filetypes = {
          "javascript", "javascriptreact", "javascript.jsx",
          "typescript", "typescriptreact", "typescript.tsx",
        },
        root_dir = require("lspconfig.util").root_pattern(
          ".oxlintrc.json", "oxlint.json"
        ),
      },
      eslint = {
        root_dir = require("lspconfig.util").root_pattern(
          ".eslintrc", ".eslintrc.js", ".eslintrc.cjs", ".eslintrc.json",
          ".eslintrc.yaml", ".eslintrc.yml",
          "eslint.config.js", "eslint.config.mjs", "eslint.config.cjs"
        ),
      },
    })
  end,
}
