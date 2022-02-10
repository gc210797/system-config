local M = {}

function M.setup()
	local on_attach = function(client, bufnr)
		local opts = {noremap = true, silent = false}
		local commons = require("commons")
		require("lsp-status").register_progress()
		require("lsp-status").on_attach(client)
	 	commons.common_bindings(bufnr, opts)
		commons.buf_set_keymap(bufnr, "<leader>di", "<cmd>PyrightOrganizeImports<CR>", opts)
		commons.buf_set_keymap(bufnr, "<leader>dm", "<cmd>lua require('dap-python').test_method()<CR>", opts)
		commons.buf_set_keymap(bufnr, "<leader>dc", "<cmd>lua require('dap-python').test_class()<CR>", opts)

		vim.cmd([[
			augroup auto_format
			autocmd!
			autocmd BufWritePost *.py lua vim.lsp.buf.formatting_sync()
			augroup end
		]])
		require('dap-python').setup("~/dap/debugpy/bin/python")
		require('dap-python').test_runner = 'pytest'
	end

	local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
	capabilities = vim.tbl_extend('keep', capabilities, require("lsp-status").capabilities)
	capabilities.textDocument.completion.completionItem.snippetSupport = true

	require("lspconfig").pyright.setup{
		on_attach = on_attach,
		capabilities = capabilities,
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "strict",
					diagnosticMode = "workspace"
				}
			}
		}

	}

	--null-ls setup for pytlint and autopep8
	local null_ls = require("null-ls")
	local sources = {
		null_ls.builtins.diagnostics.pylint.with({
			method = null_ls.methods.DIAGNOSTICS_ON_SAVE
		}),
		null_ls.builtins.formatting.autopep8
	}

	null_ls.register(sources)
end

return M
