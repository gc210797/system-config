local M = {}

function M.setup()
	local on_attach = function(client, bufnr)
		require("lsp-status").register_progress()
		require("lsp-status").on_attach(client)

		local opts = {noremap = true, silent = false}

		require("commons").common_bindings(bufnr, opts)

	end


	local sumneko_path = vim.env.HOME .. "/lsp/lua-language-server"
	local sumneko_binary = sumneko_path .. "/bin/lua-language-server"
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
