local M = {}

function M.setup()
	require('lspconfig').pylsp.setup{}
	local on_attach = function(client, bufnr)
		require("lsp-status").register_progress()
		require("lsp-status").on_attach(client)
	 	require("commons").common_bindings(bufnr, {noremap = true, silent = false})
	end

	local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
	capabilities = vim.tbl_extend('keep', capabilities, require("lsp-status").capabilities)
	capabilities.textDocument.completion.completionItem.snippetSupport = true

	require("lspconfig").pylsp.setup{
		on_attach = on_attach,
		capabilities = capabilities,
		settings = {
			pylsp = {
				plugins = {
					pylint = {enabled = true, executable = "pylint"},
					jedi_completion = {fuzzy = true},
					pyls_isort = {enabled = true},
					pylsp_mypy = {enabled = true},
					pyflakes = {enabled = false},
					pycodestyle = {enabled = false}
				}
			}
		},
		flags = {
			debounce_text_changes = 200
		}
	}
end

return M
