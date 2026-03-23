-- conform.nvim – formatter configuration.
-- See https://github.com/stevearc/conform.nvim
local js_ts_filetypes = {
  "javascript", "javascriptreact", "javascript.jsx",
  "typescript", "typescriptreact", "typescript.tsx",
}

local oxfmt_configs = { "oxfmt.toml", ".oxfmt.toml" }
local prettier_configs = {
  ".prettierrc", ".prettierrc.json",
  ".prettierrc.yml", ".prettierrc.yaml",
  ".prettierrc.js", ".prettierrc.cjs", ".prettierrc.mjs",
  "prettier.config.js", "prettier.config.cjs", "prettier.config.mjs",
}

local function js_ts_formatters(bufnr)
  local dir = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr))
  local opts = { upward = true, path = dir }
  local formatters = {}
  if vim.fs.find(oxfmt_configs, opts)[1] then
    table.insert(formatters, "oxfmt")
  end
  if vim.fs.find(prettier_configs, opts)[1] then
    table.insert(formatters, "prettier")
  end
  return formatters
end

return {
  "stevearc/conform.nvim",
  opts = function(_, opts)
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    for _, ft in ipairs(js_ts_filetypes) do
      opts.formatters_by_ft[ft] = js_ts_formatters
    end
    return opts
  end,
}
