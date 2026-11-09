return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local ts = require 'nvim-treesitter'

      -- Parsers and queries install under `stdpath('data')/site` by default.
      ts.setup()

      local ensure_installed = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'http',
        'rust',
        'css',
        'go',
        'astro',
        'gitignore',
        'svelte',
        'javascript',
        'jsdoc',
        'typescript',
        'tsx',
        'vue',
        'scss',
        'json',
        'yaml',
        'toml',
        'dockerfile',
        'python',
      }

      local installed = ts.get_installed 'parsers'
      local missing = vim.tbl_filter(function(lang)
        return not vim.tbl_contains(installed, lang)
      end, ensure_installed)
      if #missing > 0 then
        ts.install(missing)
      end

      -- Some languages depend on vim's regex highlighting system (such as Ruby)
      -- for indent rules, so keep syntax on and treesitter indenting off there.
      local additional_vim_regex_highlighting = { ruby = true }

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('treesitter-start', { clear = true }),
        desc = 'Start treesitter highlighting and indenting',
        callback = function(args)
          local lang = vim.treesitter.language.get_lang(args.match)
          -- `add` returns nil when no parser is installed for the language.
          if not lang or not vim.treesitter.language.add(lang) then
            return
          end

          vim.treesitter.start(args.buf, lang)

          if additional_vim_regex_highlighting[args.match] then
            vim.bo[args.buf].syntax = 'on'
          else
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
