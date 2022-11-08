local M  = {}

function M.setup()
	vim.cmd "autocmd User TelescopePreviewerLoaded setlocal number"
	require('telescope').setup{
		defaults = {
			mappings = {
				i = {
					["<esc>"] = require("telescope.actions").close
				}
			},
			vimgrep_arguments = {
				"rg",
				--"--color=never",
				"--no-heading",
				"--with-filename",
				"--line-number",
				"--column",
				"--smart-case",
				"--trim"
			},
		},
		extensions = {
			fzf = {
				fuzzy = true,
				override_generic_sorter = true,
				override_file_sorter = true,
				case_mod = "smart_case"
			}
		}
	}

	require('telescope').load_extension('fzf')
    require('telescope').load_extension('ui-select')
end

return M
