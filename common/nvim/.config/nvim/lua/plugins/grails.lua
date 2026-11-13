-- Grails: GSP grammar and navigation (go to definition, :GrailsAlternate).
-- The plugin ships `lsp/grails.lua`, so enabling the server is all it needs.
-- The `gsp` parser is installed through treesitter.lua.
return {
  'vdassios/grails.nvim',
  dev = true,
  lazy = false,
  config = function()
    vim.lsp.enable 'grails'
  end,
}
