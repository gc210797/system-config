return require('packer').startup(function()
	use 'wbthomason/packer.nvim'
	use 'morhetz/gruvbox'
	use 'cespare/vim-toml'
	use 'stephpy/vim-yaml'
	use 'rust-lang/rust.vim'
	use 'airblade/vim-rooter'
	use {'junegunn/fzf', run = function() vim.fn['fzf#install']() end}
	use 'junegunn/fzf.vim'
	use 'preservim/nerdtree'
	use {
		'hoob3rt/lualine.nvim',
		requires = {'kyazdani42/nvim-web-devicons', opt = true}
	}
	use 'neovim/nvim-lspconfig'
	use 'mfussenegger/nvim-dap'
	use 'nvim-lua/lsp_extensions.nvim'
	use 'nvim-lua/completion-nvim'
	use 'mfussenegger/nvim-jdtls'
	use 'nvim-lua/lsp-status.nvim'
	use 'mhartington/formatter.nvim'
	use {
  		'nvim-telescope/telescope.nvim',
  		requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
	}

	use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }

	use "onsails/lspkind-nvim"
	use "glepnir/lspsaga.nvim"
end)
