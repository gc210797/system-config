vim.cmd([[
set shell=/bin/bash
]]
)
vim.g.mapleader = ' '

require('plugins')

vim.opt.background = 'dark'
vim.opt.clipboard:append {"unnamedplus"}
vim.cmd([[
syntax on
filetype plugin indent on
hi Pmenu ctermbg=black ctermfg=white
set splitright
set splitbelow
set incsearch
set ignorecase
set smartcase
set gdefault
set number relativenumber
augroup jdtls_lsp
	autocmd!
	autocmd FileType java lua require('jdtls_setup').setup()
augroup end
]])

vim.opt.completeopt = {'menuone', 'noinsert', 'noselect'}
vim.opt.shortmess = vim.opt.shortmess + "c"
vim.opt.updatetime = 300

vim.g["fzf_layout"] = {down = '~20%'}

vim.api.nvim_set_keymap('n', '<Leader>s', ':Rg ', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>;', ':Buffers<CR>', {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '?', "?\\v", {noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '/', "/\\v", {noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<leader>n', ':NERDTreeToggle<CR>', {noremap = true, silent = true});

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = true,
    update_in_insert = true,
})

require("lspkind").init()
require("lspsaga").init_lsp_saga()
require("dapui").setup()
require("rust_setup").setup()
require("lualine").setup{
	options = {theme = 'gruvbox'},
	sections = {lualine_c = {"os.data('%a')", 'data', require'lsp-status'.status_progress}}
}
