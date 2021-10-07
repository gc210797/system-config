local M = {}

function M.setup()
	local on_attach = function(client, bufnr)
		require("lsp-status").register_progress()
		require("lsp-status").on_attach(client)
		local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, 'n', ...) end

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

	end


	local sumneko_path = vim.env.HOME .. "/lsp/lua-language-server"
	local sumneko_binary = sumneko_path .. "/bin/Linux/lua-language-server"
	local runtime_path = vim.split(package.path, ';')
	table.insert(runtime_path, "lua/?.lua")
	table.insert(runtime_path, "lua/?/init.lua")

	local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
	capabilities = vim.tbl_extend('keep', capabilities, require("lsp-status").capabilities)

	require("lspconfig").sumneko_lua.setup {
		cmd = {sumneko_binary, "-E", sumneko_path .. "/main.lua"},
		on_attach = on_attach,
		root_dir = function()
			return os.getenv("HOME") .. "/.config/nvim/"
		end,
		settings = {
			Lua = {
				runtime = {
					version = 'LuaJIT',
					path = runtime_path
				},
				diagnostics = {
					globals = {'vim'}
				},
				workspace = {
					library = vim.api.nvim_get_runtime_file("", true)
				},
				telemetry = {
					emable = false
				}
			}
		},
		capabilities = capabilities
	}
end

return M
