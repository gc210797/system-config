return require('packer').startup(function()
	use 'wbthomason/packer.nvim'
	use 'eddyekofo94/gruvbox-flat.nvim'
	use 'cespare/vim-toml'
	use 'stephpy/vim-yaml'
	use 'rust-lang/rust.vim'
	use 'airblade/vim-rooter'
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
	use 'nvim-lua/plenary.nvim'

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
		run = ':TSUpdate',
		before = "neorg"
	}

	use 'nvim-telescope/telescope.nvim'
	use {'nvim-telescope/telescope-ui-select.nvim' }


	use 'jose-elias-alvarez/null-ls.nvim'

	use 'mfussenegger/nvim-dap-python'
	use 'theHamsta/nvim-dap-virtual-text'
	use { 'TimUntersberger/neogit' }
	use { 'sindrets/diffview.nvim' }
	use {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
	use {
	    "nvim-neorg/neorg",
	    config = function()
		require("neorg").setup {
			load = {
				["core.defaults"] = {},
				["core.integrations.telescope"] = {},
				["core.gtd.base"] = {
					config = {
						workspace = "ws"
					}
				},
				["core.gtd.ui"] = {},
				["core.norg.concealer"] = {},
				["core.norg.journal"] = {},
				["core.norg.qol.toc"] = {},
				["core.norg.qol.todo_items"] = {},
				["core.norg.dirman"] = {
					config = {
						workspaces = {
							ws = "~/neorg"
						},
						autochdir = true,
						index = "index.norg"
					}
				}
			}
		}
	    end,
	    requires = "nvim-neorg/neorg-telescope" -- Be sure to pull in the repo
	}
end)
