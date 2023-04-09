local M = {}

local library = {}

local function add_to_lib(lib)
	for _, p in pairs(vim.fn.expand(lib, false, true)) do
		p = vim.loop.fs_realpath(p)
		if p ~= nil then
			library[p] = true
		end
	end
end

add_to_lib("$VIMRUNTIME")
add_to_lib(vim.fn.stdpath("config"))
add_to_lib("~/.local/share/nvim/site/pack/packer/start/*")
add_to_lib("~/.local/share/nvim/site/pack/packer/opt/*")

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

	local capabilities = require('cmp_nvim_lsp').default_capabilities(vim.lsp.protocol.make_client_capabilities())
	capabilities = vim.tbl_extend('keep', capabilities, require("lsp-status").capabilities)

	require("lspconfig").lua_ls.setup {
		cmd = {sumneko_binary, "-E", sumneko_path .. "/main.lua"},
		on_attach = on_attach,
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
					library = library
				},
				telemetry = {
					enable = false
				}
			}
		},
		capabilities = capabilities
	}
end

return M
