local M = {}


local parser_configs = require('nvim-treesitter.parsers').get_parser_configs()
parser_configs.norg_meta = {
	install_info = {
		url = "https://github.com/nvim-neorg/tree-sitter-norg-meta",
		files = { "src/parser.c" },
		branch = "main"
	}
}

parser_configs.norg_table = {
	install_info = {
		url = "https://github.com/nvim-neorg/tree-sitter-norg-table",
		files = {"src/parser.c"},
		branch = "main"
	}
}

function M.setup()
	require('nvim-treesitter.configs').setup {
		ensure_installed = "all",
		sync_install = false,
		ignore_install = {},
		highlight = {
			enable = true,
			enable_autocmd = false
		},
		autopairs = {
			enable = true
		},
		incremental_selection = {
			enable = true,
		},
		indent = {
			enable = true,
			disable = {"python", "yaml"}
		},
		rainbow = {
			enable = true,
			disable = {"html"},
			extended_mode = false,
			max_file_lines = nil
		},
		autotag = {
			enable = true
		}
	}
end

return M
