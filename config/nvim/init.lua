require('config.options')
require('config.keybinds')
require('config.lazy')
require('config.devshell')

--Diagnostics not going out of the screen
vim.diagnostic.config({
  virtual_text = false,
  virtual_lines = { current_line = true }, -- only for the line under the cursor
})
