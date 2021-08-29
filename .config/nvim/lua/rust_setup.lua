local M = {}

function M.setup()
	vim.g["rustfmt_autosave"] = 1
	vim.cmd([[
		autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *.rs :lua require('lsp_extensions').inlay_hints{ prefix = ' » ', highlight = "NonText", enabled = {"TypeHint", "ChainingHint", ParameterHint}}
	]])


	local on_attach = function(client, bufnr)
		require("lsp-status").register_progress()
		require("lsp-status").on_attach(client)
		local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, 'n', ...) end
		local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, 'n', ...) end

		local opts = {noremap = true, silent = false}

		buf_set_keymap('[g', '<cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_prev()<CR>', opts)
		buf_set_keymap(']g', '<cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_next()<CR>', opts)
		buf_set_keymap('gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
		buf_set_keymap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
		buf_set_keymap("gs", "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>", opts)

		buf_set_keymap('gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
		
		buf_set_keymap('gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
		
		buf_set_keymap('<leader>e', '<cmd>lua require("lspsaga.diagnostic").show_line_diagnostics()<CR>', opts)

		buf_set_keymap('K', '<cmd>lua require("lspsaga.hover").render_hover_doc()<CR>', opts)
		buf_set_keymap('rn', '<cmd>lua require("lspsaga.rename").rename()<CR>', opts)
		buf_set_keymap('ga', '<cmd>lua require("lspsaga.codeaction").code_action()<CR>', opts)
		buf_set_keymap('<C-f>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>", opts)
		buf_set_keymap('<C-b>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>", opts)

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
