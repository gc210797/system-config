return require('packer').startup(function()
	use 'wbthomason/packer.nvim'
	use 'ellisonleao/gruvbox.nvim'
	use 'cespare/vim-toml'
	use 'stephpy/vim-yaml'
	use 'rust-lang/rust.vim'
	use 'airblade/vim-rooter'
	use {
		'hoob3rt/lualine.nvim',
		requires = {'kyazdani42/nvim-web-devicons'}
	}
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons'
        }
    }
	use 'neovim/nvim-lspconfig'
	use 'mfussenegger/nvim-dap'
	use 'mfussenegger/nvim-jdtls'
	use 'nvim-lua/lsp-status.nvim'
	use 'mhartington/formatter.nvim'
	use 'nvim-lua/plenary.nvim'

	use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap", "nvim-neotest/nvim-nio"} }

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
		run = ':TSUpdate',
	}

	use 'nvim-telescope/telescope.nvim'
	use {'nvim-telescope/telescope-ui-select.nvim' }

	use 'jose-elias-alvarez/null-ls.nvim'

	use 'mfussenegger/nvim-dap-python'
	use 'theHamsta/nvim-dap-virtual-text'
	use { 'TimUntersberger/neogit' }
	use { 'sindrets/diffview.nvim' }
	use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    use {'iamcco/markdown-preview.nvim', config = "vim.call('mkdp#util#install')"}
    use 'simrat39/rust-tools.nvim'
    use 'folke/zen-mode.nvim'
    use {
        'coffebar/neovim-project',
        requires = {
            { "Shatur/neovim-session-manager" },
        }
    }
    use {
        "scalameta/nvim-metals",
        requires = {
            {"j-hui/fidget.nvim"}
        }
    }
end)
