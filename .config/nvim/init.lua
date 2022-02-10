--vim.cmd([[
--set shell=/bin/bash
--]]
--)
vim.g.mapleader = ' '

require('plugins')

vim.opt.background = 'dark'
vim.opt.clipboard:append {"unnamedplus"}
vim.g.gruvbox_flat_style = "hard"
vim.g.nvim_tree_group_empty = 1
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
set autochdir
colorscheme gruvbox-flat
augroup jdtls_lsp
	autocmd!
	autocmd FileType java lua require('jdtls_setup').setup()
augroup end
]])

vim.opt.completeopt = {'menuone', 'noinsert', 'noselect'}
vim.opt.shortmess = vim.opt.shortmess + "c"
vim.opt.updatetime = 300
vim.opt.mouse = "a"
vim.opt.signcolumn = "yes"
vim.opt.termguicolors = true

--vim.g["fzf_layout"] = {down = '~20%'}

vim.api.nvim_set_keymap('n', '<Leader>s', ':Rg ', {noremap = true})
vim.api.nvim_set_keymap('n', '<Leader>;', ':Buffers<CR>', {silent = true, noremap = true})
vim.api.nvim_set_keymap('n', '?', "?\\v", {noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '/', "/\\v", {noremap = true, silent = false})
vim.api.nvim_set_keymap('n', '<leader>n', ':NvimTreeToggle<CR>', {noremap = true, silent = true});
vim.api.nvim_set_keymap('n', '<leader>r', ':NvimTreeRefresh<CR>', {noremap = true, silent = true});

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
    vim.lsp.diagnostic.on_publish_diagnostics, {
    virtual_text = false,
    signs = true,
    update_in_insert = true,
})

local dap, dapui = require("dap"), require("dapui")


require("lspkind").init()
dapui.setup()
require("cmp_setup").setup()
require("rust_setup").setup()
require("lua_setup").setup()
require("ts").setup()
require("python_setup").setup()
require("lualine").setup{
	options = {theme = 'gruvbox-flat'},
	sections = {lualine_c = {"os.data('%a')", 'data', require'lsp-status'.status_progress}}
}
require("treesitter").setup()

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open()
end

dap.listeners.after.event_terminated["dapui_config"] = function()
	dapui.close()
end

dap.listeners.after.event_exited["dapui_config"] = function()
	dapui.close()
end

require('nvim-dap-virtual-text').setup {
	commented = true
}
