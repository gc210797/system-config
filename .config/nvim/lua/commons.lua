local M = {};

function M.buf_set_keymap(bufnr, ...)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', ...)
end

function M.buf_set_option(bufnr, ...)
	vim.api.nvim_buf_set_option(bufnr, ...)
end

function M.common_bindings(bufnr, opts)
		M.buf_set_keymap(bufnr, '[g', '<cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_prev()<CR>', opts)
		M.buf_set_keymap(bufnr, ']g', '<cmd>lua require("lspsaga.diagnostic").lsp_jump_diagnostic_next()<CR>', opts)
		M.buf_set_keymap(bufnr, 'gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
		M.buf_set_keymap(bufnr, 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
		M.buf_set_keymap(bufnr, "gs", "<cmd>lua require('lspsaga.signaturehelp').signature_help()<CR>", opts)

		M.buf_set_keymap(bufnr, 'gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

		M.buf_set_keymap(bufnr, 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

		M.buf_set_keymap(bufnr, '<leader>e', '<cmd>lua require("lspsaga.diagnostic").show_line_diagnostics()<CR>', opts)

		M.buf_set_keymap(bufnr, 'K', '<cmd>lua require("lspsaga.hover").render_hover_doc()<CR>', opts)
		M.buf_set_keymap(bufnr, 'rn', '<cmd>lua require("lspsaga.rename").rename()<CR>', opts)
		M.buf_set_keymap(bufnr, 'ga', '<cmd>lua require("lspsaga.codeaction").code_action()<CR>', opts)
		M.buf_set_keymap(bufnr, '<C-f>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>", opts)
		M.buf_set_keymap(bufnr, '<C-b>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>", opts)
end

return M
