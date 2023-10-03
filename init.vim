call plug#begin("~/.vim/plugged")

Plug 'tpope/vim-sensible'

Plug 'antoinemadec/FixCursorHold.nvim'

" Collection of common configurations for the Nvim LSP client
Plug 'neovim/nvim-lspconfig'

" Completion framework
Plug 'hrsh7th/nvim-cmp'

" Formatting on save
Plug 'lukas-reineke/lsp-format.nvim'

" LSP completion source for nvim-cmp
Plug 'hrsh7th/cmp-nvim-lsp'

" Snippet completion source for nvim-cmp
Plug 'hrsh7th/cmp-vsnip'

" Other usefull completion sources
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-buffer'

" Snippet engine
Plug 'hrsh7th/vim-vsnip'
Plug 'simrat39/rust-tools.nvim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}  " We recommend updating the parsers on update
Plug 'nvim-treesitter/nvim-treesitter-refactor'
Plug 'mfussenegger/nvim-treehopper'
" telescope
Plug 'nvim-lua/popup.nvim'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'AckslD/nvim-neoclip.lua'

Plug 'rhysd/vim-fixjson'

" replace
Plug 'windwp/nvim-spectre'

" debugging
" Plug 'mfussenegger/nvim-dap'

" tree file viewer
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'kyazdani42/nvim-tree.lua'

Plug 'tpope/vim-commentary'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-dispatch'

Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

Plug 'hashivim/vim-terraform'

" git
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'f-person/git-blame.nvim'
Plug 'windwp/nvim-autopairs'


" themes
" Plug 'jim-at-jibba/ariake-vim-colors' 
" Plug 'sainnhe/sonokai'
" Plug 'sainnhe/gruvbox-material'
" Plug 'shaunsingh/nord.nvim'
Plug 'cocopon/iceberg.vim'
" Plug 'jim-at-jibba/ariake-vim-colors'

" tabs
Plug 'kyazdani42/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'

Plug 'rcarriga/nvim-notify'

Plug 'ggandor/lightspeed.nvim'
Plug 'kylechui/nvim-surround'

Plug 'github/copilot.vim'
Plug 'voldikss/vim-floaterm'

" markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install'  }

call plug#end()

if (has("termguicolors"))
 set termguicolors
endif
set shell=/bin/bash

" Theme
" let g:sonokai_style = 'andromeda'
syntax enable
filetype plugin indent on
set background=dark
colorscheme iceberg
:set clipboard=unnamed
:highlight SpecialComment guifg=#6b7089

:lang en_US.UTF-8
set number
set mouse=a

let mapleader = " "

" Set completeopt to have a better completion experience
" :help completeopt
" menuone: popup even when there's only one match
" noinsert: Do not insert text until a selection is made
" noselect: Do not select, force user to select one from the menu
set completeopt=menuone,noinsert,noselect

" Avoid showing extra messages when using completion
set shortmess+=c

lua << EOF
require('telescope').load_extension('neoclip')
require('neoclip').setup()
require('nvim-autopairs').setup{}
require("lsp-format").setup {}

local nvim_lsp = require'lspconfig'
nvim_lsp.gopls.setup {
  on_attach = require("lsp-format").on_attach,
  cmd = {"gopls", "serve"},
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}

require'lspconfig'.sourcekit.setup{
  cmd = {'/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/sourcekit-lsp'}
}

nvim_lsp.denols.setup {
  on_attach = require("lsp-format").on_attach,
  init_options = {
    lint = true,
  },
}

nvim_lsp.tsserver.setup {
  on_attach = require("lsp-format").on_attach,
  init_options = {
    lint = true,
  },
}

local opts = {
    tools = { -- rust-tools options
        autoSetHints = true,
        inlay_hints = {
            show_parameter_hints = true,
            parameter_hints_prefix = "",
            other_hints_prefix = "",
        },
    },

    -- all the opts to send to nvim-lspconfig
    -- these override the defaults set by rust-tools.nvim
    -- see https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#rust_analyzer
    server = {
        on_attach = require("lsp-format").on_attach,
        -- on_attach is a callback called when the language server attachs to the buffer
        -- on_attach = on_attach,
        settings = {
            -- to enable rust-analyzer settings visit:
            -- https://github.com/rust-analyzer/rust-analyzer/blob/master/docs/user/generated_config.adoc
            ["rust-analyzer"] = {
              cargo = {
                 features = "all",
                },
              diagnostics = {
                disabled = { "unresolved-proc-macro" }
                },
                -- enable clippy on save
                checkOnSave = {
                    command = "clippy",
                },
            },
        },
    },
}

require('rust-tools').setup(opts)


local cmp = require'cmp'
cmp.setup({
  -- Enable LSP snippets
  snippet = {
    expand = function(args)
        vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    -- Add tab support
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Insert,
      select = true,
    })
  },

  -- Installed sources
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'path' },
    { name = 'buffer' },
    { name = 'copilot'},
  },
})



require'nvim-treesitter.configs'.setup {
  ensure_installed = { "go", "rust", "typescript" },
  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,
  highlight = {
    -- `false` will disable the whole extension
    enable = true,
    disable = function(lang, buf)
      return vim.api.nvim_buf_line_count(buf) > 50000
    end,
  },
  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,
  refactor = {
    smart_rename = {
      enable = true,
      keymaps = {
        smart_rename = "<leader>rs",
      },
    },
    highlight_definitions = { 
      enable = true,
      disable = function(lang, buf)
        return vim.api.nvim_buf_line_count(buf) > 50000
      end,
    },
    highlight_current_scope = { enable = false },
  },
  incremental_selection = {
    enable = true,
    disable = function(lang, buf)
      return vim.api.nvim_buf_line_count(buf) > 50000
    end,
    keymaps = {
      init_selection = "<leader>a", -- set to `false` to disable one of the mappings
      node_incremental = "<leader>ai",
      scope_incremental = "<leader>as",
      node_decremental = "<leader>ar",
    },
  },
}

require('nvim-tree').setup()
vim.notify = require('notify')
EOF

" Code navigation shortcuts
nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
nnoremap <silent> <c-k> <cmd>lua vim.lsp.buf.signature_help()<CR>
nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
nnoremap <silent> gd    <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap <silent> ga    <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <silent> gs    <cmd>lua vim.diagnostic.open_float()<CR>
nnoremap <silent> gn    <cmd>lua vim.diagnostic.get_next()<CR>

nnoremap <silent> rn    <cmd>lua vim.lsp.buf.rename()<CR>
nnoremap <leader>gh    <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>clr   <cmd>lua vim.lsp.codelens.refresh()<CR>
nnoremap <leader>cle   <cmd>lua vim.lsp.codelens.run()<CR>
nnoremap <leader>ft    <cmd>:FloatermNew --name=myfloat --height=0.8 --width=0.7 --autoclose=2 <CR>
nnoremap   <silent>   <F12>   :FloatermToggle<CR>
noremap <Leader>s :update<CR>

" Set updatetime for CursorHold
" 300ms of no cursor movement to trigger CursorHold
" let g:cursorhold_updatetime=300
" Show diagnostic popup on cursor hold
" autocmd CursorHold,CursorHoldI * lua vim.diagnostic.show_line_diagnostics({focusable=false})

" nvim-tree
nnoremap <C-n> :NvimTreeToggle<CR>
nnoremap <leader>rr :NvimTreeRefresh<CR>
nnoremap <leader>n :NvimTreeFindFile<CR>

" Goto previous/next diagnostic warning/error
nnoremap <silent> g[ <cmd>lua vim.diagnostic.goto_prev()<CR>
nnoremap <silent> g] <cmd>lua vim.diagnostic.goto_next()<CR>

" telescope
nnoremap <leader>c <cmd>Telescope commands<cr>
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>
nnoremap <leader>fr <cmd>Telescope lsp_references<cr>
nnoremap <leader>fd <cmd>Telescope lsp_definitions<cr>
nnoremap <leader>fi <cmd>Telescope lsp_implementations<cr>
nnoremap <leader>fd <cmd>Telescope lsp_type_definitions<cr>
nnoremap <leader>p <cmd>Telescope neoclip<cr>
nnoremap <leader>t <cmd>Telescope treesitter<cr>
nnoremap <leader>re <cmd>Telescope resume<cr>
nnoremap <leader>fm <cmd>Telescope marks<cr>
nnoremap <leader>tt <cmd>Telescope lsp_dynamic_workspace_symbols<cr>
omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>
xnoremap <silent> m :lua require('tsht').nodes()<CR>

" Tabs setup
" Move to previous/next
nnoremap <silent>    <A-,> :BufferPrevious<CR>
nnoremap <silent>    <A-.> :BufferNext<CR>
" Re-order to previous/next
nnoremap <silent>    <≤> :BufferMovePrevious<CR>
nnoremap <silent>    <≥> :BufferMoveNext<CR>
" Goto buffer in position...
nnoremap <silent>    <A-1> :BufferGoto 1<CR>
nnoremap <silent>    <A-2> :BufferGoto 2<CR>
nnoremap <silent>    <A-3> :BufferGoto 3<CR>
nnoremap <silent>    <A-4> :BufferGoto 4<CR>
nnoremap <silent>    <A-5> :BufferGoto 5<CR>
nnoremap <silent>    <A-6> :BufferGoto 6<CR>
nnoremap <silent>    <A-7> :BufferGoto 7<CR>
nnoremap <silent>    <A-8> :BufferGoto 8<CR>
nnoremap <silent>    <A-9> :BufferLast<CR>
" Pin/unpin buffer
nnoremap <silent>    <A-p> :BufferPin<CR>
" Close buffer
nnoremap <silent>    <A-c> :BufferClose<CR>

" replace
nnoremap <leader>r <cmd>lua require('spectre').open()<CR>

"search current word
nnoremap <leader>rw <cmd>lua require('spectre').open_visual({select_word=true})<CR>
vnoremap <leader>r <esc>:lua require('spectre').open_visual()<CR>
"  search in current file
nnoremap <leader>rp viw:lua require('spectre').open_file_search()<cr>
" run command :Spectre

" markdown-preview config
"" set to 1, nvim will open the preview window after entering the markdown buffer
" default: 0
let g:mkdp_auto_start = 0 
" set to 1, the nvim will auto close current preview window when change
" from markdown buffer to another buffer
" default: 1
let g:mkdp_auto_close = 1

" Rust aliases
:com Test Dispatch cargo test
:com Check Dispatch cargo check
:com Build Dispatch cargo Build
:com Clippy Dispatch cargo clippy --all-features
:com Run Dispatch cargo run

" spellcheck
setlocal spell spelllang=en_us

" set auto read files on change
set autoread
au FocusGained,WinLeave,WinEnter,FocusLost,BufEnter * :checktime


" hcl formatting for NATS configs
au BufRead,BufNewFile *.conf setfiletype hcl

" write on exit insert mdoe
" :autocmd InsertLeave * silent! update

:set number

" Automamatic switch between relative and absolute line numbers
:augroup numbertoggle
:  autocmd!
:  autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu && mode() != "i" | set rnu   | endif
:  autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu                  | set nornu | endif
:augroup END
