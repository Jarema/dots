local null_ls = require("null-ls")
local diagnostics = null_ls.builtins.diagnostics

-- Setup none-ls with linters only (formatting is handled by LSP)
null_ls.setup({
    -- Force consistent offset encoding with other LSP clients
    on_attach = function(client, bufnr)
        client.server_capabilities.positionEncoding = "utf-16"
    end,
    sources = {
        -- Go linting with golangci-lint
        diagnostics.golangci_lint.with({
            extra_args = { "--fast" }, -- Use fast mode for better performance
        }),
        -- Note: Clippy is handled by rust-analyzer, not none-ls
    },
    
    -- Configure diagnostic display
    diagnostic_config = {
        underline = true,
        virtual_text = false,
        signs = true,
        update_in_insert = false,
        severity_sort = true,
    },
})

-- Create :Lint command to manually trigger linting
vim.api.nvim_create_user_command("Lint", function()
    local ft = vim.bo.filetype
    
    -- Save file first
    vim.cmd("silent! write")
    
    if ft == "rust" then
        -- For Rust, save and refresh diagnostics
        vim.notify("Running clippy...")
        -- Force rust-analyzer to refresh by toggling diagnostics
        local clients = vim.lsp.get_active_clients({ bufnr = 0 })
        for _, client in ipairs(clients) do
            if client.name == "rust_analyzer" then
                -- Clear and refresh diagnostics
                vim.diagnostic.reset(nil, 0)
                -- Force a workspace reload to trigger clippy
                client.request("rust-analyzer/reloadWorkspace", nil, function(err, result)
                    if err then
                        -- If reload workspace doesn't work, try just saving again to trigger check
                        vim.cmd("silent! write")
                    end
                end, 0)
            end
        end
    else
        -- For other languages, refresh none-ls
        vim.notify("Running linters...")
        require("null-ls").toggle({})  -- Toggle off and on to force refresh
        require("null-ls").toggle({})
    end
    
    -- Show diagnostic summary after a delay
    vim.defer_fn(function()
        local diagnostics = vim.diagnostic.get(0)
        local error_count = #vim.tbl_filter(function(d) return d.severity == vim.diagnostic.severity.ERROR end, diagnostics)
        local warning_count = #vim.tbl_filter(function(d) return d.severity == vim.diagnostic.severity.WARN end, diagnostics)
        local info_count = #vim.tbl_filter(function(d) return d.severity == vim.diagnostic.severity.INFO end, diagnostics)
        local hint_count = #vim.tbl_filter(function(d) return d.severity == vim.diagnostic.severity.HINT end, diagnostics)
        
        local msg = string.format("Linting complete: %d errors, %d warnings, %d info, %d hints", 
            error_count, warning_count, info_count, hint_count)
        vim.notify(msg)
    end, 3000)  -- Increased delay to allow clippy to complete
end, { desc = "Run linter for current buffer" })

-- Create keybinding for linting
vim.keymap.set("n", "<leader>li", "<cmd>Lint<cr>", { desc = "Run linter" })

