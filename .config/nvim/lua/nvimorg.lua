local M = {}

function M.setup()

	require('orgmode').setup_ts_grammar()

	require('nvim-treesitter.configs').setup {
		highlight = {
			enable = true,
			disable = {'org'},
			additional_vim_regex_highlighting = {'org'},
		},
		ensure_installed = {'org'}
	}

	require('orgmode').setup({
		org_agenda_file = {"~/org/*"},
		org_default_notes_file = '~/org/refile.org'
	})

end

return M
