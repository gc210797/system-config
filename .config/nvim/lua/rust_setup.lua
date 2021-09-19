local M = {}

function M.setup()
	vim.g["rustfmt_autosave"] = 1
	vim.cmd([[
		autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *.rs :lua require('lsp_extensions').inlay_hints{ prefix = ' » ', highlight = "NonText", enabled = {"TypeHint", "ChainingHint", ParameterHint}}
	]])


	local on_attach = function(client, bufnr)
		require("lsp-status").register_progress()
		require("lsp-status").on_attach(client)
	 	require("commons").common_bindings(bufnr, {noremap = true, silent = false})
		require('completion').on_attach(client)
	end

	require('lspconfig').rust_analyzer.setup{
		on_attach = on_attach,
		flags = {
			debounce_text_changes = 150,
		},
		capabilities = require("lsp-status").capabilities
	}

	local dap = require("dap")
	dap.adapters.lldb = {
		type = 'executable',
		command = 'lldb-vscode',
		name = 'lldb'
	}
	dap.configurations.rust = {
		{
			name = "Launch",
			type = "lldb",
			request = "launch",
			program = function()
				return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. '/', 'file')
			end,
			cwd = "${workspaceFolder}",
			stopOnEntry = false,
			args = {},
			runInTerminal = false
		}
	}
end

return M
