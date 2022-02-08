local M = {}

function M.setup()
	local on_attach = function(_, buffer)
		require('jdtls.setup').add_commands()
		require('lsp-status').register_progress()
		require('jdtls').setup_dap({ hotcodereplace = 'auto' })

		local opts = {noremap = true, silent = false}
		local commons = require("commons")

		commons.common_bindings(buffer, opts)


		commons.buf_set_keymap(buffer, '<leader>di', "<cmd>lua require('jdtls').organize_imports()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>dt', "<cmd>lua require('jdtls').test_class()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>dn', "<cmd>lua require('jdtls').test_nearest_method()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>de', "<cmd>lua require('jdtls').extract_variable()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>df', "<cmd>lua require('jdtls').test_class()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>dn', "<cmd>lua require('jdtls').test_nearest_method()<CR>", opts)

		vim.api.nvim_exec([[
			augroup FormatJavaAuGroup
				autocmd!
				autocmd BufWritePost *.java lua vim.lsp.buf.formatting()
			augroup end
			hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
			hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
			hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
			augroup lsp_document_highlight
				autocmd!
				autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
				autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
			augroup end
		]], false)

	end

	local root_markers = {'pom.xml', 'gradle.build', '.git'}
	local root_dir = require('jdtls.setup').find_root(root_markers)
	local home = os.getenv('HOME')

	local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
	capabilities = vim.tbl_extend('keep', capabilities, require("lsp-status").capabilities)

	local workspace_folder = home .. '/.workspace/' .. vim.fn.fnamemodify(root_dir, ':p:h:t')
	local config = {
		flags = {
			allow_incremental_sync = true
		},
		capabilities = capabilities
	}

	config.settings = {
		java = {
			signatureHelp = {enabled = true},
			contentProvider = {preferred = 'fernflower'},
			completion = {
				favoriteStaticMembers = {
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.mockito.Mockito.*"
				}
			},
			format = {
				settings = {
					url = home .. "/lsp/formatter/eclipse-formatter.xml"
				}
			},
			sources = {
				organizeImports = {
					starThreshold = 9999,
					staticStarThreshold = 9999
				}
			},
			codeGeneration = {
				toString = {
					template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}"
				}
			},
			configuration = {
				runtimes = {
					{
						name = "JavaSE-11",
						path = "/etc/alternatives/java_sdk_11/"
					}
				}
			}
		},
	}

	config.cmd = {
		'java',
		'-Declipse.application=org.eclipse.jdt.ls.core.id1',
		'-Dosgi.bundles.defaultStartLevel=4',
		'-Declipse.product=org.eclipse.jdt.ls.core.product',
		'-Dlog.protocol=true',
		'-Dlog.level=ALL',
		'-Xms1g',
		'--add-modules=ALL-SYSTEM',
		'--add-opens', 'java.base/java.util=ALL-UNNAMED',
		'--add-opens', 'java.base/java.lang=ALL-UNNAMED',
		'-jar', home .. '/lsp/jdt-language-server-latest/plugins/org.eclipse.equinox.launcher_1.6.400.v20210924-0641.jar',
		'-configuration', home .. '/lsp/jdt-language-server-latest/config_linux/',
		'-data', workspace_folder
	}
	config.on_attach = on_attach
	config.on_init = function(client, _)
		client.notify('workspace/didChangeConfiguration', {settings = config.settings})
	end

	local bundles = {}

	local jar_patterns = {
		"/dap/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
		"/dap/vscjava.vscode-java-test-0.34.0/extension/server/*.jar"
	}

	for _, jar_pattern in ipairs(jar_patterns) do
		for _, bundle in ipairs(vim.split(vim.fn.glob(home .. jar_pattern), '\n')) do
			table.insert(bundles, bundle)
		end
	end


	local extendedClientCapabilities = require('jdtls').extendedClientCapabilities
	extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
	config.init_options = {
		extendedClientCapabilities = extendedClientCapabilities,
		bundles = bundles
	}

	require('jdtls').start_or_attach(config)
end

return M
