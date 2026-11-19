-- Grails and Groovy: GSP grammar, :GrailsAlternate, and two language servers the plugin ships configs for:
-- `grails_ls` (grails-language-server: Groovy and GSP, run on $JAVA_HOME, the project's JDK through SDKMAN auto-env;
-- jar from :GrailsInstallServer) and `grails` (in-process Lua navigation, steps aside where grails_ls is ready).
-- The `gsp` parser is installed through treesitter.lua.
return {
  'vdassios/grails.nvim',
  dev = true,
  lazy = false,
  config = function()
    vim.lsp.enable { 'grails', 'grails_ls' }
  end,
}
