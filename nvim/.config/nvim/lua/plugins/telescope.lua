-- NOTE: Plugins can specify dependencies.
--
-- The dependencies are proper plugin specifications as well - anything
-- you do for a plugin at the top level, you can do for a dependency.
--
-- Use the `dependencies` key to specify the dependencies of a particular plugin

return {
  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      { -- If encountering errors, see telescope-fzf-native README for installation instructions
        'nvim-telescope/telescope-fzf-native.nvim',

        -- `build` is used to run some command when the plugin is installed/updated.
        -- This is only run then, not every time Neovim starts up.
        build = 'make',

        -- `cond` is a condition used to determine whether this plugin should be
        -- installed and loaded.
        cond = function()
          return vim.fn.executable 'make' == 1
        end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },
      { 'nvim-telescope/telescope-file-browser.nvim' },

      -- Useful for getting pretty icons, but requires a Nerd Font.
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      -- Telescope is a fuzzy finder that comes with a lot of different things that
      -- it can fuzzy find! It's more than just a "file finder", it can search
      -- many different aspects of Neovim, your workspace, LSP, and more!
      --
      -- The easiest way to use Telescope, is to start by doing something like:
      --  :Telescope help_tags
      --
      -- After running this command, a window will open up and you're able to
      -- type in the prompt window. You'll see a list of `help_tags` options and
      -- a corresponding preview of the help.
      --
      -- Two important keymaps to use while in Telescope are:
      --  - Insert mode: <c-/>
      --  - Normal mode: ?
      --
      -- This opens a window that shows you all of the keymaps for the current
      -- Telescope picker. This is really useful to discover what Telescope can
      -- do as well as how to actually do it!

      local actions = require 'telescope.actions'
      local fb_actions = require('telescope').extensions.file_browser.actions
      -- [[ Configure Telescope ]]
      -- See `:help telescope` and `:help telescope.setup()`
      require('telescope').setup {
        -- You can put your default mappings / updates / etc. in here
        --  All the info you're looking for is in `:help telescope.setup()`
        --
        defaults = {
          wrap_results = true,
          layout_strategy = 'horizontal',
          -- layout_config = { height = 0.95 },
          layout_config = { horizontal = { prompt_position = 'bottom', preview_width = 0.7 } },
          file_ignore_patterns = { 'backup', '.git/', '^node_modules/', '%.jpeg', '%.png', '%-lock.json' },
          sorting_strategy = 'ascending',
          winblend = 0,
          mappings = {
            n = {},
          },
          -- mappings = {
          --   i = { ['<c-enter>'] = 'to_fuzzy_refine' },
          -- },
        },
        -- pickers = {
        --   diagnostics = {
        --     theme = 'ivy',
        --     initial_mode = 'normal',
        --     layout_config = {
        --       preview_cutoff = 9999,
        --     },
        --   },
        -- },
        extensions = {
          ['ui-select'] = {
            require('telescope.themes').get_dropdown(),
          },
          file_browser = {
            theme = 'dropdown',
            -- disables netrw and use telescope-file-browser in its place
            hijack_netrw = true,
            mappings = {
              -- your custom insert mode mappings
              ['n'] = {
                -- your custom normal mode mappings
                ['N'] = fb_actions.create,
                ['h'] = fb_actions.goto_parent_dir,
                ['/'] = function()
                  vim.cmd 'startinsert'
                end,
                ['<C-u>'] = function(prompt_bufnr)
                  for i = 1, 10 do
                    actions.move_selection_previous(prompt_bufnr)
                  end
                end,
                ['<C-d>'] = function(prompt_bufnr)
                  for i = 1, 10 do
                    actions.move_selection_next(prompt_bufnr)
                  end
                end,
                ['<PageUp>'] = actions.preview_scrolling_up,
                ['<PageDown>'] = actions.preview_scrolling_down,
              },
            },
          },
        },
      }

      -- Enable Telescope extensions if they are installed
      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')
      pcall(require('telescope').load_extension, 'file_browser')

      -- See `:help telescope.builtin`
      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', ';t', builtin.help_tags, { desc = 'Lists available help tags and opens a new window with the relevant help info on <cr>"' })
      vim.keymap.set('n', ';f', function()
        builtin.find_files {
          no_ignore = false,
          hidden = true,
        }
      end, { desc = 'Lists files in your current working directory, respects .gitignore' })
      vim.keymap.set('n', ';r', function()
        builtin.live_grep { additional_args = { '--hidden' } }
      end, { desc = 'Search for a string in your current working directory and get results live as you type, respects .gitignore' })
      vim.keymap.set('n', ';e', builtin.diagnostics, { desc = 'Lists Diagnostics for all open buffers or a specific buffer' })
      vim.keymap.set('n', ';q', builtin.quickfix, { desc = 'Lists items in the quickfix list' })
      vim.keymap.set('n', ';s', builtin.treesitter, { desc = 'Lists Function names, variables, from Treesitter' })
      vim.keymap.set('n', ';;', builtin.resume, { desc = 'Resume the previous telescope picker' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
      vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', 'sf', function()
        local telescope = require 'telescope'

        local function telescope_buffer_dir()
          return vim.fn.expand '%:p:h'
        end

        telescope.extensions.file_browser.file_browser {
          path = '%:p:h',
          cwd = telescope_buffer_dir(),
          respect_gitignore = false,
          hidden = true,
          grouped = true,
          previewer = false,
          initial_mode = 'normal',
          layout_config = { height = 40 },
        }
      end, { desc = 'Open File Browser with the path of the current buffer' })

      -- Slightly advanced example of overriding default behavior and theme
      vim.keymap.set('n', '<leader>/', function()
        -- You can pass additional configuration to Telescope to change the theme, layout, etc.
        builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
          winblend = 10,
          previewer = false,
        })
      end, { desc = '[/] Fuzzily search in current buffer' })

      -- It's also possible to pass additional configuration options.
      --  See `:help telescope.builtin.live_grep()` for information about particular keys
      vim.keymap.set('n', '<leader>s/', function()
        builtin.live_grep {
          grep_open_files = true,
          prompt_title = 'Live Grep in Open Files',
        }
      end, { desc = '[S]earch [/] in Open Files' })

      -- Shortcut for searching your Neovim configuration files
      vim.keymap.set('n', '<leader>sn', function()
        builtin.find_files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
