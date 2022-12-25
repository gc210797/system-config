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
			},
            file_browser = {
                hijack_netrw = true,
                grouped = true,
                collapse_dirs = true,
                depth = false,
                auto_depth = true,
                hide_parent_dir = true,
                dir_icon = ""
            }
		}
	}

	require('telescope').load_extension('fzf')
    require('telescope').load_extension('ui-select')
    require('telescope').load_extension('file_browser')
end

return M
