-- AstroLSP configuration – LSP server setup.
-- See https://docs.astronvim.com/recipes/advanced_lsp/
return {
	"AstroNvim/astrolsp",
	---@param opts AstroLSPOpts
	opts = function(plugin, opts)
		opts.servers = opts.servers or {}
		table.insert(opts.servers, "codebook")
		table.insert(opts.servers, "eslint")

		opts.config = {
			codebook = {
				cmd = { "codebook-lsp", "serve" },
				filetypes = { "*" },
				root_dir = require("lspconfig.util").root_pattern("codebook.toml", ".codebook.toml", ".git"),
				on_attach = function(client, _)
					local ns = vim.lsp.diagnostic.get_namespace(client.id)
					vim.diagnostic.config({ virtual_text = false, signs = false }, ns)
				end,
			},
		}
	end,
}
