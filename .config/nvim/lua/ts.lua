local M = {}

function M.setup()
	local on_attach = function(client, bufnr)
		require("lsp-status").register_progress()
		require("lsp-status").on_attach(client)
	 	require("commons").common_bindings(bufnr, {noremap = true, silent = false})
		require('completion').on_attach(client)
	end

	require("lspconfig").tsserver.setup {
		on_attach = on_attach,
		capabilities = require("lsp-status").capabilities,
		init_options = {
			hostInfo = "neovim",
			includeCompletionsForModuleExports = true,
			includeCompletionsForImportStatements = true,
			allowRenameOfImportPath = true
		}
	}
end

return M
