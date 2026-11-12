-- Java: jdtls through nvim-java, which downloads jdtls and the JDK it runs on.
-- nvim-java's lazy.lua pulls in its own dependencies (nui.nvim, nvim-dap, spring-boot.nvim).
-- jdtls is not installed through Mason, so it is not in lspconfig.lua's `servers` table.

-- One runtime per SDKMAN JDK major version, highest patch wins. Empty without SDKMAN.
local function sdkman_runtimes()
  local best = {}
  for _, dir in ipairs(vim.fn.glob(vim.fn.expand '~' .. '/.sdkman/candidates/java/*', false, true)) do
    local file = io.open(dir .. '/release')
    local version = file and file:read('*a'):match 'JAVA_VERSION="([^"]+)"'
    if file then
      file:close()
    end
    local v = version and vim.fs.basename(dir) ~= 'current' and vim.version.parse(version, { strict = false })
    if v then
      local name = v.major == 1 and 'JavaSE-1.' .. v.minor or 'JavaSE-' .. v.major
      if not best[name] or vim.version.gt(v, best[name].version) then
        best[name] = { version = v, path = dir }
      end
    end
  end
  local runtimes = {}
  for name, r in vim.spairs(best) do
    table.insert(runtimes, { name = name, path = r.path })
  end
  return runtimes
end

return {
  'nvim-java/nvim-java',
  config = function()
    require('java').setup {
      -- spring-boot.nvim starts its server on $JAVA_HOME with -XX:+UseZGC, which JDK 11 rejects
      spring_boot_tools = { enable = false },
    }

    local settings = {
      java = {
        configuration = { runtimes = sdkman_runtimes() },
        import = {
          -- keep .project, .classpath, .settings/ out of the project tree
          generatesMetadataFilesAtProjectRoot = false,
          gradle = {
            -- Gradle runs on the project's JDK (SDKMAN auto-env sets JAVA_HOME), not on jdtls's newer one
            java = { home = vim.env.JAVA_HOME },
            -- fixes Grails source layouts and exposes compiled Groovy classes to Java
            arguments = '-I ' .. vim.fn.stdpath 'config' .. '/gradle/jdtls.init.gradle',
            -- otherwise jdtls writes .factorypath and bin/generated-sources into the project
            annotationProcessing = { enabled = false },
          },
        },
      },
    }

    vim.lsp.config('jdtls', {
      root_markers = { { 'settings.gradle', 'settings.gradle.kts' }, { 'pom.xml', 'build.gradle', 'build.gradle.kts' }, '.git' },
      settings = settings,
      -- jdtls reads the import settings at startup from initializationOptions; `settings` arrive too late
      init_options = { settings = settings },
      -- the setting alone does not stop the metadata files; the JVM property is needed as well
      cmd_env = { JDK_JAVA_OPTIONS = '-Djava.import.generatesMetadataFilesAtProjectRoot=false' },
    })
    vim.lsp.enable 'jdtls'
  end,
}
-- vim: ts=2 sts=2 sw=2 et
