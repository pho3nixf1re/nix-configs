-- AstroCore configuration – editor options, key mappings, and autocommands.
-- See https://docs.astronvim.com/configuration/customizing_plugins
return {
  "AstroNvim/astrocore",
  opts = {
    options = {
      opt = {
        relativenumber = true, -- relative line numbers
        number         = true, -- absolute line number on current line
        spell          = true,
        signcolumn     = "yes",
        wrap           = false,
      },
    },
    -- Add or override key mappings here, e.g.:
    -- mappings = {
    --   n = {
    --     ["<Leader>w"] = { "<cmd>w<cr>", desc = "Save file" },
    --   },
    -- },
  },
}
