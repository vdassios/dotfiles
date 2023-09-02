local keymap = vim.keymap

-- Alternate Esc bind
keymap.set('i', 'jk', '<ESC>')
keymap.set('i', 'kj', '<ESC>')

-- Double Esc to clear highlights
keymap.set('n', '<ESC><ESC>', ':noh<cr>', { silent = true })

-- Do not yank with x
keymap.set('n', 'x', '"_x')

-- Increment / Decrement
keymap.set('n', '+', '<C-a>')
keymap.set('n', '-', '<C-x>')

keymap.set('n', '<Leader>s', ':set spell!<cr>', { silent = true })
keymap.set('i', '<Leader>s<C-0>', ':set spell!<cr>', { silent = true })

-- tab in general mode will move to next buffer
keymap.set('n', '<tab>', ':bnext<cr>')
-- shift-tab to move to previous buffer
keymap.set('n', '<s-tab>', ':bprevious<cr>')

-- Better tabbing
-- keymap.set('v', '<', '<gv')
-- keymap.set('v', '>', '>gv')

-- Select all, TODO: better map
-- keymap.set('n', '<C-a>', 'gg<S-v>G')

-- New tab, not sure if I want this yet
keymap.set('n', 'te', ':tabedit<Return>', { silent = true })
keymap.set('n', 'ss', ':split<Return><C-w>w', { silent = true })
keymap.set('n', 'sv', ':vsplit<Return><C-w>w', { silent = true })

-- Window navigation, consistent with tmux panel navigation
--keymap.set('n', '<Space>', '<C-w>w')
keymap.set('', '<C-h>', '<C-w>h')
keymap.set('', '<C-k>', '<C-w>k')
keymap.set('', '<C-j>', '<C-w>j')
keymap.set('', '<C-l>', '<C-w>l')

-- leader key is \
