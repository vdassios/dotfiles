local status, ts = pcall(require, 'nvim-treesitter.configs')
if (not status) then return end

ts.setup {
  highlight = {
    enable = true,
    disable = {},
  },
  indent = {
    enable = true,
    disable = {},
  },
  ensure_installed = {
    "markdown",
    "markdown_inline",
    'tsx',
    'lua',
    'json',
    'javascript',
    'css',
    'python',
    'html',
    'yaml',
    'bash',
    'elixir',
    'heex',
    'eex',
    'prisma'
  },
  autotag = {
    enable = true,
  },
  -- comments, use gcc
  config = {
    javascript = {
      __default = '// %s',
      jsx_element = '{/* %s */}',
      jsx_fragment = '{/* %s */}',
      jsx_attribute = '// %s',
      comment = '// %s',
    }
  }
}

-- this is for custom tsx. see treesitter docs for how to add custom parsers
-- will be useful for projects with tsx/jsx files
local parser_config = require "nvim-treesitter.parsers".get_parser_configs()
parser_config.tsx.filetype_to_parsername = { "javascript", "typescript.tsx" }
