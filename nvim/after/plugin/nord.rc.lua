local status, no = pcall(require, "nord")
if (not status) then return end


-- Load the colorscheme
no.set()
