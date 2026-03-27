return {
	-- Register nixfmt directly with none-ls (no Mason needed)
	{
		"nvimtools/none-ls.nvim",
		dependencies = { "nvimtools/none-ls-extras.nvim" },
		opts = function(_, opts)
			local null_ls = require("null-ls")
			opts.sources = opts.sources or {}

			table.insert(opts.sources, null_ls.builtins.formatting.nixfmt)

			-- oxfmt: prefer a project-level config; fall back to ~/.oxfmtrc.json
			-- when none exists
			table.insert(
				opts.sources,
				require("none-ls.formatting.oxfmt").with({
					extra_args = function(params)
						local project_configs = { ".oxfmtrc.json", ".oxfmtrc.jsonc", "oxfmt.config.ts" }
						for _, f in ipairs(project_configs) do
							if vim.fn.filereadable(params.root .. "/" .. f) == 1 then
								return {} -- project config found; let oxfmt discover it normally
							end
						end
						local global = vim.fn.expand("~/.oxfmtrc.json")
						if vim.fn.filereadable(global) == 1 then
							return { "-c", global }
						end
						return {}
					end,
				})
			)
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
