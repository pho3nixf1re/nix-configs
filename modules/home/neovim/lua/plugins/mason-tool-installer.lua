-- mason-tool-installer – automatically install/update Mason packages.
-- See https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim
return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	opts = {
		ensure_installed = {
			"codebook",

			-- JavaScript, Typescript
			"eslint-lsp",
			"oxfmt",
			"oxlint",
			"typescript-language-server", -- ts_ls

			-- lua
			"stylua",
			"lua-language-server", -- lua_ls
		},
	},
}
