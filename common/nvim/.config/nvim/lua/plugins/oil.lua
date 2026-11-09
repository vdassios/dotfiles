return {
  {
    'stevearc/oil.nvim',
    lazy = false,
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    keys = {
      { 'sf', '<cmd>Oil<cr>', desc = 'Open File Browser with the path of the current buffer' },
    },
    opts = {
      default_file_explorer = true,
      view_options = {
        show_hidden = true,
      },
    },
  },
}
-- vim: ts=2 sts=2 sw=2 et
