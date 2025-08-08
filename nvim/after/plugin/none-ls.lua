local null_ls = require("null-ls")
local diagnostics = null_ls.builtins.diagnostics

-- Setup none-ls with linters only (formatting is handled by LSP)
null_ls.setup({
    sources = {
        -- Go linting with golangci-lint
        diagnostics.golangci_lint.with({
            extra_args = { "--fast" }, -- Use fast mode for better performance
        }),
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
    
    -- For Rust files, use cargo clippy
    if ft == "rust" then
        -- Run cargo clippy and capture output
        vim.notify("Running cargo clippy...")
        vim.fn.jobstart("cargo clippy --message-format=short", {
            on_exit = function(_, exit_code)
                if exit_code == 0 then
                    vim.notify("Clippy check complete - no issues found")
                else
                    vim.notify("Clippy check complete - see diagnostics")
                end
                -- Trigger LSP to re-check for diagnostics
                vim.cmd("silent! write")
                vim.cmd("LspRestart")
            end
        })
    else
        -- For other languages, just save to trigger linters
        vim.cmd("silent! write")
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
    end, 1000)
end, { desc = "Run linter for current buffer" })

-- Create keybinding for linting
vim.keymap.set("n", "<leader>li", "<cmd>Lint<cr>", { desc = "Run linter" })

