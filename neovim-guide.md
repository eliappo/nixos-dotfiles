# Neovim + clangd Setup Guide

## Dependencies

### System packages

Install these before anything else:

```bash
# Ubuntu/Debian
sudo apt install neovim clangd ripgrep fd-find git

# Arch
sudo pacman -S neovim clangd ripgrep fd git

# macOS (homebrew)
brew install neovim llvm ripgrep fd git
```

`ripgrep` (`rg`) and `fd` are required by Telescope for fast searching.

### NixOS

```nix
environment.systemPackages = with pkgs; [
  neovim
  clang-tools  # includes clangd
  ripgrep
  fd
  git
];
```

---

## Directory structure

```
~/.config/nvim/
├── init.lua
└── lua/
    └── plugins/
        ├── lsp.lua
        ├── telescope.lua
        └── lint.lua
```

---

## `init.lua` — bootstrap lazy.nvim

```lua
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Leader key (set before plugins load)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Core options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true
vim.opt.updatetime = 250

require("lazy").setup("plugins")
```

---

## `lua/plugins/lsp.lua` — LSP + completion

```lua
return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            -- Autocompletion
            'hrsh7th/nvim-cmp',
            'hrsh7th/cmp-buffer',
            'hrsh7th/cmp-path',
            'hrsh7th/cmp-nvim-lsp',
            -- Snippets
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'rafamadriz/friendly-snippets',
        },
        config = function()
            -- Rounded borders on hover/signature windows
            vim.lsp.handlers['textDocument/hover'] = vim.lsp.with(
                vim.lsp.handlers.hover, { border = 'rounded' }
            )
            vim.lsp.handlers['textDocument/signatureHelp'] = vim.lsp.with(
                vim.lsp.handlers.signature_help, { border = 'rounded' }
            )

            -- Diagnostics appearance
            vim.diagnostic.config({
                virtual_text = true,
                severity_sort = true,
                float = { style = 'minimal', border = 'rounded', header = '', prefix = '' },
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = '✘',
                        [vim.diagnostic.severity.WARN]  = '▲',
                        [vim.diagnostic.severity.HINT]  = '⚑',
                        [vim.diagnostic.severity.INFO]  = '»',
                    },
                },
            })

            -- Merge cmp capabilities into lspconfig defaults
            local lspconfig = require('lspconfig')
            local capabilities = require('cmp_nvim_lsp').default_capabilities()

            -- clangd setup
            lspconfig.clangd.setup({
                capabilities = capabilities,
                cmd = {
                    "clangd",
                    "--background-index",
                    "--clang-tidy",
                    "--header-insertion=iwyu",
                    "--completion-style=detailed",
                    "--function-arg-placeholders",
                },
            })

            -- Keymaps on LSP attach
            vim.api.nvim_create_autocmd('LspAttach', {
                callback = function(event)
                    local opts = { buffer = event.buf }
                    vim.keymap.set('n', 'K',          vim.lsp.buf.hover,           opts)
                    vim.keymap.set('n', 'gd',         vim.lsp.buf.definition,      opts)
                    vim.keymap.set('n', 'gD',         vim.lsp.buf.declaration,     opts)
                    vim.keymap.set('n', 'gi',         vim.lsp.buf.implementation,  opts)
                    vim.keymap.set('n', 'go',         vim.lsp.buf.type_definition, opts)
                    vim.keymap.set('n', 'gr',         vim.lsp.buf.references,      opts)
                    vim.keymap.set('n', 'gs',         vim.lsp.buf.signature_help,  opts)
                    vim.keymap.set('n', 'gl',         vim.diagnostic.open_float,   opts)
                    vim.keymap.set('n', '[d',         vim.diagnostic.goto_prev,    opts)
                    vim.keymap.set('n', ']d',         vim.diagnostic.goto_next,    opts)
                    vim.keymap.set('n', '<F2>',       vim.lsp.buf.rename,          opts)
                    vim.keymap.set({'n','x'}, '<F3>', function()
                        vim.lsp.buf.format({ async = true })
                    end, opts)
                    vim.keymap.set('n', '<F4>',       vim.lsp.buf.code_action,     opts)

                    -- Auto-format C/C++ on save
                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    if client and vim.tbl_contains({ "c", "cpp" }, vim.bo.filetype) then
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = event.buf,
                            callback = function()
                                vim.lsp.buf.format({ bufnr = event.buf, id = client.id })
                            end,
                        })
                    end
                end,
            })

            -- nvim-cmp setup
            local cmp = require('cmp')
            require('luasnip.loaders.from_vscode').lazy_load()

            cmp.setup({
                snippet = {
                    expand = function(args)
                        require('luasnip').lsp_expand(args.body)
                    end,
                },
                window = {
                    documentation = cmp.config.window.bordered(),
                },
                completion = { completeopt = 'menu,menuone,noinsert' },
                sources = {
                    { name = 'nvim_lsp' },
                    { name = 'luasnip', keyword_length = 2 },
                    { name = 'buffer',  keyword_length = 3 },
                    { name = 'path' },
                },
                formatting = {
                    fields = { 'abbr', 'menu', 'kind' },
                    format = function(entry, item)
                        local labels = {
                            nvim_lsp = '[LSP]',
                            luasnip  = '[Snip]',
                            buffer   = '[Buf]',
                            path     = '[Path]',
                        }
                        item.menu = labels[entry.source.name] or '[?]'
                        return item
                    end,
                },
                mapping = cmp.mapping.preset.insert({
                    ['<CR>']    = cmp.mapping.confirm({ select = false }),
                    ['<Tab>']   = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item({ behavior = 'select' })
                        else
                            fallback()
                        end
                    end, { 'i', 's' }),
                    ['<S-Tab>'] = cmp.mapping.select_prev_item({ behavior = 'select' }),
                    ['<C-e>']   = cmp.mapping(function()
                        if cmp.visible() then cmp.abort() else cmp.complete() end
                    end),
                    ['<C-f>']   = cmp.mapping.scroll_docs(5),
                    ['<C-u>']   = cmp.mapping.scroll_docs(-5),
                    ['<C-d>']   = cmp.mapping(function(fallback)
                        local ls = require('luasnip')
                        if ls.jumpable(1) then ls.jump(1) else fallback() end
                    end, { 'i', 's' }),
                    ['<C-b>']   = cmp.mapping(function(fallback)
                        local ls = require('luasnip')
                        if ls.jumpable(-1) then ls.jump(-1) else fallback() end
                    end, { 'i', 's' }),
                }),
            })
        end,
    },
}
```

---

## `lua/plugins/telescope.lua`

```lua
return {
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            'nvim-lua/plenary.nvim',
            -- Native sorter — much faster on large repos
            { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
        },
        config = function()
            local telescope = require('telescope')
            local builtin   = require('telescope.builtin')

            telescope.setup({
                defaults = {
                    layout_strategy = 'horizontal',
                    sorting_strategy = 'ascending',
                    layout_config = { prompt_position = 'top' },
                },
            })
            telescope.load_extension('fzf')

            -- Keymaps
            vim.keymap.set('n', '<leader>ff', builtin.find_files,               { desc = 'Find files' })
            vim.keymap.set('n', '<leader>fg', builtin.live_grep,                { desc = 'Live grep' })
            vim.keymap.set('n', '<leader>fb', builtin.buffers,                  { desc = 'Buffers' })
            vim.keymap.set('n', '<leader>fh', builtin.help_tags,                { desc = 'Help tags' })
            vim.keymap.set('n', '<leader>fr', builtin.lsp_references,           { desc = 'LSP references' })
            vim.keymap.set('n', '<leader>fd', builtin.diagnostics,              { desc = 'Diagnostics' })
            vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols,     { desc = 'Document symbols' })
            vim.keymap.set('n', '<leader>/',  builtin.current_buffer_fuzzy_find, { desc = 'Fuzzy find in buffer' })
        end,
    },
}
```

---

## `lua/plugins/lint.lua` — clang-tidy via nvim-lint

```lua
return {
    {
        'mfussenegger/nvim-lint',
        event = { 'BufReadPre', 'BufNewFile' },
        config = function()
            local lint = require('lint')
            lint.linters_by_ft = {
                c   = { 'clangtidy' },
                cpp = { 'clangtidy' },
            }
            -- Lint on save and when leaving insert mode
            vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
                callback = function()
                    lint.try_lint()
                end,
            })
        end,
    },
}
```

> `clang-tidy` ships with `clang-tools` / `llvm`. Same binary as clangd.
> Create `.clang-tidy` in project root to control checks:
> ```yaml
> Checks: 'clang-diagnostic-*,clang-analyzer-*,modernize-*,readability-*'
> ```

---

## `compile_commands.json`

clangd needs this to understand your build. Generate it:

```bash
# CMake
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
ln -s build/compile_commands.json .

# Bear (any build system)
bear -- make

# Meson
meson setup build
ln -s build/compile_commands.json .
```

---

## Vim kickstart — essential keybinds

### Modes

| Key | Action |
|-----|--------|
| `i` | Insert mode |
| `Esc` / `Ctrl-[` | Normal mode |
| `v` | Visual mode |
| `V` | Visual line mode |
| `Ctrl-v` | Visual block mode |
| `:` | Command mode |

### Navigation (Normal mode)

| Key | Action |
|-----|--------|
| `h j k l` | Left / down / up / right |
| `w` / `b` | Next / prev word |
| `0` / `$` | Line start / end |
| `gg` / `G` | File start / end |
| `Ctrl-d` / `Ctrl-u` | Half-page down / up |
| `%` | Jump to matching bracket |
| `*` | Search word under cursor |
| `n` / `N` | Next / prev search result |

### Editing

| Key | Action |
|-----|--------|
| `dd` | Delete line |
| `yy` | Yank (copy) line |
| `p` / `P` | Paste after / before |
| `u` | Undo |
| `Ctrl-r` | Redo |
| `ciw` | Change inner word |
| `di(` | Delete inside parentheses |
| `.` | Repeat last change |
| `>>` / `<<` | Indent / dedent line |

### LSP keymaps (active in C/C++ files)

| Key | Action |
|-----|--------|
| `K` | Hover docs |
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | List references |
| `gl` | Show diagnostics float |
| `[d` / `]d` | Prev / next diagnostic |
| `<F2>` | Rename symbol |
| `<F3>` | Format buffer |
| `<F4>` | Code actions |

### Telescope keymaps (`<leader>` = `Space`)

| Key | Action |
|-----|--------|
| `Space ff` | Find files |
| `Space fg` | Live grep (requires `rg`) |
| `Space fb` | Open buffers |
| `Space fh` | Search help tags |
| `Space fr` | LSP references |
| `Space fd` | Diagnostics list |
| `Space fs` | Document symbols |
| `Space /` | Fuzzy search current buffer |

Inside Telescope: `Ctrl-j/k` move selection, `Enter` open, `Ctrl-t` open tab, `Esc` close.

---

## Built-in Vim documentation

Vim's help system is comprehensive. Use it:

```
:help                     top-level help index
:help <topic>             jump to topic (e.g. :help gg, :help ins-special-keys)
:help lsp                 neovim LSP docs
:help diagnostic          diagnostics API
:help vim.keymap.set      keymap API
:help telescope.nvim      after installing, plugin docs
```

Navigating help buffers:

| Key | Action |
|-----|--------|
| `Ctrl-]` | Follow tag under cursor |
| `Ctrl-o` | Jump back |
| `K` | Look up word under cursor in help |

Search help with Telescope: `Space fh` — fuzzy-match across all installed plugin docs and built-in vim help.

---

## First launch

```bash
nvim
```

lazy.nvim auto-installs all plugins on first open. Watch progress with `:Lazy`. Once done, open a `.c` file — clangd starts automatically if `compile_commands.json` exists in project root.

Check LSP status: `:LspInfo`
Check active linters: `:lua require('lint').linters_by_ft`
