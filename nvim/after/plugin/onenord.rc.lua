local status, ono = pcall(require, "onenord")
if (not status) then return end

-- Load the colorscheme
ono.setup({
  comment_italics = true,
  -- for transparent background
  -- disable = { background = true },
  --
  custom_colors = {
    bg = "#2E3440cc",
    highlight = "#363c4b"
    -- should maybe darken the rest of the highlight colors as well
  },
})
