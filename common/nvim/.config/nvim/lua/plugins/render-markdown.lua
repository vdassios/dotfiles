-- render-markdown
-- https://github.com/MeanderingProgrammer/render-markdown.nvim
--
-- Renders headings, code blocks, tables, checkboxes, etc. inline in markdown
-- buffers. The plugin lazy-loads itself by filetype, so no lazy.nvim trigger.
-- Catppuccin's `auto_integrations` themes it.

return {
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  ---@module 'render-markdown'
  ---@type render.md.UserConfig
  opts = {},
}
-- vim: ts=2 sts=2 sw=2 et
