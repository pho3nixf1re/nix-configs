-- conform.nvim – formatter configuration.
-- See https://github.com/stevearc/conform.nvim
local js_ts_filetypes = {
  "javascript", "javascriptreact", "javascript.jsx",
  "typescript", "typescriptreact", "typescript.tsx",
}

local function has_config(files)
  return function(_, ctx)
    return vim.fs.find(files, { upward = true, path = ctx.dirname })[1] ~= nil
  end
end

local oxfmt_condition = has_config({ "oxfmt.toml", ".oxfmt.toml" })
local prettier_condition = has_config({
  ".prettierrc",
  ".prettierrc.json",
  ".prettierrc.yml",
  ".prettierrc.yaml",
  ".prettierrc.js",
  ".prettierrc.cjs",
  ".prettierrc.mjs",
  "prettier.config.js",
  "prettier.config.cjs",
  "prettier.config.mjs",
})

local ft_formatters = {}
for _, ft in ipairs(js_ts_filetypes) do
  ft_formatters[ft] = { "oxfmt", "prettier" }
end

return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = ft_formatters,
    formatters = {
      oxfmt = {
        condition = oxfmt_condition,
      },
      prettier = {
        condition = prettier_condition,
      },
    },
  },
}
