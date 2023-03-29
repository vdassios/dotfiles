require('base')
require('highlights')
require('maps')
require('plugins')

-- sync clipboard to yanks & vice-versa
local has = vim.fn.has
local is_unix = has "unix"

if is_unix then
  return vim.opt.clipboard:append { 'unnamedplus' }
end
-- 

