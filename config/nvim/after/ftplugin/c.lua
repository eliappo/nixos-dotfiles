local set = vim.opt_local

-- Linux kernel style: 8-space tabs
set.shiftwidth = 8
set.tabstop = 8
set.softtabstop = 8
set.expandtab = false  -- Use actual tabs, not spaces
set.cindent = true

-- Prevent comment reformatting
set.formatoptions:remove({ 'c', 'r', 'o' })
-- c = Auto-wrap comments using textwidth
-- r = Auto-insert comment leader after <Enter>
-- o = Auto-insert comment leader after 'o' or 'O'

-- Optional: Add other Linux kernel coding style settings
set.textwidth = 80
set.colorcolumn = "81"
