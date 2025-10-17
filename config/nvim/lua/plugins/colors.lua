local function enable_transparency()
    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
     -- Split windows and buffers
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })  -- Non-current windows
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "none" })
    
    -- Floating windows (Telescope, etc)
    vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
    vim.api.nvim_set_hl(0, "FloatTitle", { bg = "none" })
    
    -- Popup menus
    vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
    vim.api.nvim_set_hl(0, "PmenuSel", { bg = "#2a2a3a" })  -- Highlighted item
    
    -- Statusline (if you want it transparent)
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
     -- Telescope specific
    vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
    vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
    vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
    vim.api.nvim_set_hl(0, "TelescopePromptTitle", { bg = "none" })
    vim.api.nvim_set_hl(0, "TelescopePreviewTitle", { bg = "none" })
    vim.api.nvim_set_hl(0, "TelescopeResultsTitle", { bg = "none" })
    -- Cursor line (subtle blend effect)
    vim.api.nvim_set_hl(0, "CursorLine", { bg = "#071E28" })  -- Subtle dark overlay
    vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#071E28" })  -- Subtle dark overlay
    vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "#0C2A34" })  -- Line number on cursor line
    -- In enable_transparency()
    vim.api.nvim_set_hl(0, "StatusLine", { bg = "none" })
    vim.api.nvim_set_hl(0, "StatusLineNC", { bg = "none" })
    
end

return {
    {
        "folke/tokyonight.nvim",
        config = function()
            vim.cmd.colorscheme "tokyonight"
            vim.cmd('hi Directory guibg=NONE')
            vim.cmd('hi SignColumn guibg=NONE')

            enable_transparency()
        end
    },
    -- {
    --     "Mofiqul/vscode.nvim",
    --     name = 'vscode',
    --     config = function()
    --         vim.cmd.colorscheme "vscode"
    --         vim.cmd('hi Directory guibg=NONE')
    --         vim.cmd('hi SignColumn guibg=NONE')
    --         enable_transparency()
    --     end
    -- }
}
