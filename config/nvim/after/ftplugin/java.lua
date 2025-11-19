-- ~/.config/nvim/after/ftplugin/java.lua

-- Check if jdtls is available
local jdtls_ok, jdtls = pcall(require, 'jdtls')
if not jdtls_ok then
    -- Fall back to basic LSP without jdtls
    vim.notify('nvim-jdtls not loaded, using basic jdtls', vim.log.levels.WARN)
    
    if vim.fn.executable('jdtls') ~= 1 then
        return
    end
    
    local workspace_dir = vim.fn.expand('~/.cache/jdtls-workspace/')
        .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    
    vim.lsp.start({
        name = 'jdtls',
        cmd = { 'jdtls', '-data', workspace_dir },
        root_dir = vim.fs.dirname(
            vim.fs.find({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'}, { upward = true })[1]
        ),
    })
    return
end

-- Full jdtls setup with nvim-jdtls plugin
if vim.fn.executable('jdtls') ~= 1 then
    vim.notify('jdt-language-server not found in PATH', vim.log.levels.WARN)
    return
end

local workspace_dir = vim.fn.expand('~/.cache/jdtls-workspace/')
    .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

local caps = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if ok then
    caps = cmp_nvim_lsp.default_capabilities()
end

local bundles = {}
local java_debug_path = vim.fn.glob('/nix/store/*-vscode-java-debug-*/share/vscode/extensions/vscjava.vscode-java-debug/server/*.jar')
if java_debug_path ~= '' then
    vim.list_extend(bundles, vim.split(java_debug_path, '\n'))
end

local config = {
    cmd = {
        'jdtls',
        '-data', workspace_dir,
    },
    root_dir = require('jdtls.setup').find_root({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'}),
    capabilities = caps,
    init_options = {
        bundles = bundles,
    },
    settings = {
        java = {
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
            },
            maven = {
                downloadSources = true,
            },
            implementationsCodeLens = {
                enabled = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            signatureHelp = {
                enabled = true,
            },
            contentProvider = {
                preferred = 'fernflower',
            },
        },
    },
    on_attach = function(client, bufnr)
        vim.keymap.set('n', '<leader>jo', jdtls.organize_imports, { buffer = bufnr })
        
        vim.keymap.set('n', '<leader>jd', function()
            pcall(require('jdtls').setup_dap, { hotcodereplace = 'auto' })
            vim.notify('Java DAP setup complete', vim.log.levels.INFO)
        end, { buffer = bufnr, desc = 'Setup Java DAP' })
    end,
}

jdtls.start_or_attach(config)
