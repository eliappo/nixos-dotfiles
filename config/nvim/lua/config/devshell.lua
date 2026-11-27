--Define the environment variable NVIM_MAKEPRG so :make will run the desired build tool
local makeprg = vim.env.NVIM_MAKEPRG

if makeprg then
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "h" },
    callback = function()
      vim.cmd.compiler("gcc")
      vim.opt_local.makeprg = makeprg
      vim.opt_local.errorformat:append("%-G%.%#")
    end,
  })

  vim.keymap.set("n", "<leader>m", "<cmd>make! | cwindow<cr>")
end
