local M = {}

function M.setup()
	require('nvim-treesitter.configs').setup {
		ensure_installed = "maintained",
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
