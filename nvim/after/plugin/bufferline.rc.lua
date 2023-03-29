local status, bufferline = pcall(require, "bufferline")
if (not status) then return end

bufferline.setup({
  -- options = {
  --   mode = "buffers",
  --   separator_style = "padded_slant",
  --   diagnostics = "nvim_lsp",
  --   always_show_bufferline = true,
  --   show_buffer_close_icons = false,
  --   show_close_icon = true,
  --   color_icons = true,
  --   numbers = "ordinal"
  -- },
  -- highlights = {
  --   separator = {
  --     fg = '#073642',
  --     bg = '#002b36',
  --   },
  --   separator_selected = {
  --     fg = '#15161E'
  --   },
  --   background = {
  --     fg = '#657b83',
  --     bg = '#002b36'
  --   },
  --   buffer_selected = {
  --     fg = '#fdf6e3',
  --     bold = true,
  --   },
  --   separator_visible = {
  --     fg = '#15161E'
  --   },
  --   fill = {
  --     bg = '#073642'
  --   }
  -- },
  highlights = {
    modified = {
      fg = '#ff9999',
    },
    modified_visible = {
      --fg = '#ff9999',
      --bg = '#fdf6e3'
    },
    modified_selected = {
      fg = '#ff1a1a'
    },
  }
})

vim.keymap.set('n', '<Tab>', '<Cmd>BufferLineCycleNext<CR>', {})
vim.keymap.set('n', '<S-Tab>', '<Cmd>BufferLineCyclePrev<CR>', {})
