return require('packer').startup(function()
	use 'wbthomason/packer.nvim'
	use 'eddyekofo94/gruvbox-flat.nvim'
	use 'cespare/vim-toml'
	use 'stephpy/vim-yaml'
	use 'rust-lang/rust.vim'
	use 'airblade/vim-rooter'
	use {'junegunn/fzf', run = function() vim.fn['fzf#install']() end}
	use 'junegunn/fzf.vim'
	use {
		'hoob3rt/lualine.nvim',
		requires = {'kyazdani42/nvim-web-devicons', opt = true}
	}
	use {
		'kyazdani42/nvim-tree.lua',
		config = function() require('nvim-tree').setup{} end
	}
	use 'neovim/nvim-lspconfig'
	use 'mfussenegger/nvim-dap'
	use 'mfussenegger/nvim-jdtls'
	use 'nvim-lua/lsp-status.nvim'
	use 'mhartington/formatter.nvim'
	use {
  		'nvim-telescope/telescope.nvim',
  		requires = {{'nvim-lua/popup.nvim'}, {'nvim-lua/plenary.nvim'}}
	}

	use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }

	use "onsails/lspkind-nvim"
	use "hrsh7th/nvim-cmp"
	use "L3MON4D3/LuaSnip"
	use "saadparwaiz1/cmp_luasnip"
	use "hrsh7th/cmp-path"
	use "hrsh7th/cmp-buffer"
	use "hrsh7th/cmp-nvim-lsp"
	use {
		'saecki/crates.nvim',
		requires = { 'nvim-lua/plenary.nvim' },
	}
	use {
		'nvim-treesitter/nvim-treesitter',
		run = ':TSUpdate'
	}
end)
