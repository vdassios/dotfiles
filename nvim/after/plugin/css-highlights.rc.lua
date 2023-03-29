local status, csscolors = pcall(require, "nvim-highlight-colors")
if (not status) then return end

csscolors.setup({
  render = 'background', -- or 'foreground' or 'first_column'
  enable_named_colors = true,
})
