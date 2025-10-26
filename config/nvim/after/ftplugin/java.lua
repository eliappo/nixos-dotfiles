-- ~/.config/nvim/after/ftplugin/java.lua
-- This works alongside your vim.lsp.config setup in lsp.lua

if vim.fn.executable('jdtls') ~= 1 then
    vim.notify('jdt-language-server not found in PATH', vim.log.levels.WARN)
    return
end

-- Generate unique workspace directory per project
local workspace_dir = vim.fn.expand('~/.cache/jdtls-workspace/')
    .. vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')

-- Get capabilities from cmp (same as your other LSP servers)
local caps = vim.lsp.protocol.make_client_capabilities()
local ok, cmp_nvim_lsp = pcall(require, 'cmp_nvim_lsp')
if ok then
    caps = cmp_nvim_lsp.default_capabilities()
end

-- Start jdtls using vim.lsp.start (bypasses vim.lsp.config for this server)
vim.lsp.start({
    name = 'jdtls',
    cmd = {
        'jdtls',
        '-data', workspace_dir,
    },
    root_dir = vim.fs.dirname(
        vim.fs.find({'.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle'}, { upward = true })[1]
    ),
    capabilities = caps,
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
})
