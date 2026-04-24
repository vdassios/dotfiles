return {
  {
    'ibhagwan/fzf-lua',
    event = 'VimEnter',
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      local fzf = require 'fzf-lua'
      fzf.setup {}
      fzf.register_ui_select()

      vim.keymap.set('n', '<leader>sk', fzf.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', ';t', fzf.help_tags, { desc = 'Lists available help tags and opens a new window with the relevant help info on <cr>' })
      vim.keymap.set('n', ';f', fzf.files, { desc = 'Lists files in your current working directory, respects .gitignore' })
      vim.keymap.set('n', ';r', function()
        fzf.live_grep { rg_opts = '--column --line-number --no-heading --color=always --smart-case --hidden --max-columns=4096 -e' }
      end, { desc = 'Search for a string in your current working directory and get results live as you type, respects .gitignore' })
      vim.keymap.set('n', ';e', fzf.diagnostics_workspace, { desc = 'Lists Diagnostics for all open buffers or a specific buffer' })
      vim.keymap.set('n', ';q', fzf.quickfix, { desc = 'Lists items in the quickfix list' })
      vim.keymap.set('n', ';s', fzf.treesitter, { desc = 'Lists Function names, variables, from Treesitter' })
      vim.keymap.set('n', ';;', fzf.resume, { desc = 'Resume the previous fzf-lua picker' })
      vim.keymap.set('n', '<leader><leader>', fzf.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set('n', '<leader>ss', fzf.builtin, { desc = '[S]earch [S]elect fzf-lua' })
      vim.keymap.set('n', '<leader>sw', fzf.grep_cword, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>s.', fzf.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>/', fzf.lgrep_curbuf, { desc = '[/] Fuzzily search in current buffer' })
      vim.keymap.set('n', '<leader>sn', function()
        fzf.files { cwd = vim.fn.stdpath 'config' }
      end, { desc = '[S]earch [N]eovim files' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
