local M = {};

function M.buf_set_keymap(bufnr, ...)
	vim.api.nvim_buf_set_keymap(bufnr, 'n', ...)
end

function M.buf_set_option(bufnr, ...)
	vim.api.nvim_buf_set_option(bufnr, ...)
end

function M.common_bindings(bufnr, opts)
		M.buf_set_keymap(bufnr, '[g', '<cmd>lua vim.diagnostic.goto_prev()<CR>', opts)
		M.buf_set_keymap(bufnr, ']g', '<cmd>lua vim.diagnostic.goto_next()<CR>', opts)
		M.buf_set_keymap(bufnr, 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
		M.buf_set_keymap(bufnr, 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
		M.buf_set_keymap(bufnr, 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
		M.buf_set_keymap(bufnr, "gs", "<cmd>lua vim.lsp.buf.signature_help()<CR>", opts)

		M.buf_set_keymap(bufnr, 'gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)

		M.buf_set_keymap(bufnr, 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)

		M.buf_set_keymap(bufnr, '<leader>e', '<cmd>lua vim.diagnostic.open_float()<CR>', opts)

		M.buf_set_keymap(bufnr, 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
		M.buf_set_keymap(bufnr, 'rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
		M.buf_set_keymap(bufnr, 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
end


function M.lsp_request(bufnr, method, params, handler)
	return vim.lsp.buf_request(bufnr, method, params, handler)
end

function M.scheduled_error(err)
	vim.schedule(function()
		vim.notify(err, vim.log.level.ERROR)
	end)
end

return M
