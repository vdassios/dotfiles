-- Gradle classpath for groovy-language-server, which cannot read Gradle builds on its own.
-- Runs gradle/classpath.init.gradle through the project's wrapper and caches the jar list
-- until a build file changes. `:GradleClasspath` (lspconfig.lua) forces a refresh.
local M = {}

local init_script = vim.fn.stdpath 'config' .. '/gradle/classpath.init.gradle'

local function cache_file(root)
  return vim.fn.stdpath 'cache' .. '/gradle-classpath/' .. vim.fn.sha256(root) .. '.json'
end

-- Newest mtime among the build files that can change the classpath (root and one level down).
local function build_stamp(root)
  local newest = 0
  local skip_hidden = function(dir)
    return not dir:match '^%.'
  end
  for name, type in vim.fs.dir(root, { depth = 2, skip = skip_hidden }) do
    if type == 'file' and (name:match '%.gradle$' or name:match '%.gradle%.kts$' or name == 'gradle.properties') then
      local stat = vim.uv.fs_stat(root .. '/' .. name)
      newest = math.max(newest, stat and stat.mtime.sec or 0)
    end
  end
  return newest
end

--- Calls `cb(jars)` with the classpath of the Gradle build at `root`; `{}` if it has no wrapper.
--- On failure warns once and never calls `cb`.
function M.resolve(root, cb)
  if not root or not vim.uv.fs_stat(root .. '/gradlew') then
    return cb {}
  end
  local cache, stamp = cache_file(root), build_stamp(root)
  local ok, cached = pcall(function()
    return vim.json.decode(table.concat(vim.fn.readfile(cache), '\n'))
  end)
  if ok and cached.stamp == stamp then
    return cb(cached.classpath)
  end

  local cmd = { './gradlew', '-q', '--console=plain', '-I', init_script, 'nvimClasspath' }
  vim.system(
    cmd,
    { cwd = root, text = true, timeout = 5 * 60 * 1000 },
    vim.schedule_wrap(function(res)
      if res.code ~= 0 then
        local lines = vim.split(vim.trim(res.stderr or ''), '\n')
        local tail = table.concat(lines, '\n', math.max(1, #lines - 4))
        vim.notify(('Gradle classpath failed in %s (exit %d):\n%s'):format(root, res.code, tail), vim.log.levels.WARN)
        return
      end
      local seen, jars = {}, {}
      for jar in res.stdout:gmatch 'NVIM_CP:([^\n]+)' do
        if not seen[jar] then
          seen[jar] = true
          table.insert(jars, jar)
        end
      end
      vim.fn.mkdir(vim.fs.dirname(cache), 'p')
      vim.fn.writefile({ vim.json.encode { stamp = stamp, classpath = jars } }, cache)
      cb(jars)
    end)
  )
end

--- Resolves the classpath for a groovyls client and pushes it to the server.
--- `refresh` drops the cache entry first.
function M.apply(client, refresh)
  if refresh and client.root_dir then
    os.remove(cache_file(client.root_dir))
  end
  M.resolve(client.root_dir, function(jars)
    -- kept in client.settings too, so a later workspace/configuration request returns the same list
    client.settings.groovy = vim.tbl_extend('force', client.settings.groovy or {}, { classpath = jars })
    client:notify('workspace/didChangeConfiguration', { settings = client.settings })
  end)
end

return M
