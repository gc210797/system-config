local M = {}

function M.setup()
	local on_attach = function(client, buffer)
		require('jdtls.setup').add_commands()
		require('lsp-status').register_progress()
		require('jdtls').setup_dap({ hotcodereplace = 'auto' })

		local opts = {noremap = true, silent = false}
		local commons = require("commons")

		commons.common_bindings(buffer, opts)


		commons.buf_set_keymap(buffer, "ga", "<cmd>lua require('jdtls').code_action()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>di', "<cmd>lua require('jdtls').organize_imports()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>dt', "<cmd>lua require('jdtls').test_class()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>dn', "<cmd>lua require('jdtls').test_nearest_method()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>de', "<cmd>lua require('jdtls').extract_variable()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>df', "<cmd>lua require('jdtls').test_class()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>dn', "<cmd>lua require('jdtls').test_nearest_method()<CR>", opts)

		require('formatter').setup {
			filetype = {
				java = {
					function()
						return {
							exe = 'java',
							args = {'-jar', os.getenv('HOME') .. '/lsp/jdtls/google-java-format.jar', vim.api.nvim_buf_get_name(0)},
							stdin = true
						}
					end
				}
			}
		}

		vim.api.nvim_exec([[
			augroup FormatJavaAuGroup
				autocmd!
				autocmd BufWritePost *.java FormatWrite
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

	local root_markers = {'pom.xml', 'gradle.build'}
	local root_dir = require('jdtls.setup').find_root(root_markers)
	local home = os.getenv('HOME')

	--local capabilities = {
	--	workspace = {
	--		configuration = true
	--	},
	--	textDocument = {
	--		completion = {
	--			completionItem = {
	--				snippetSupport = true
	--			}
	--		}
	--	}
	--}

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
		['java.format.settings.url'] = home .. '/lsp/jdtls/java-google-formatter.xml',
		['java.format.settings.profile'] = 'GoogleStyle',
		java = {
			signatureHelp = {enable = true},
			contentProvider = {preferred = 'fernflower'},
			completion = {
				favoriteStaticMembers = {
					"org.junit.jupiter.api.Assertions.*",
					"java.util.Objects.requireNonNull",
					"java.util.Objects.requireNonNullElse",
					"org.mockito.Mockito.*"
				}
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
	}

	config.cmd = {home .. '/lsp/jdtls/jdtls.sh', workspace_folder}
	config.on_attach = on_attach
	config.on_init = function(client, _)
		client.notify('workspace/didChangeConfiguration', {settings = config.settings})
	end

	local bundles = {}

	local jar_patterns = {
		"/lsp/jdtls/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
		"/lsp/jdtls/vscode-java-test/server/*.jar"
	}

	for _, jar_pattern in ipairs(jar_patterns) do
		for _, bundle in ipairs(vim.split(vim.fn.glob(home .. jar_pattern), '\n')) do
			if not vim.endswith(bundle, "com.microsoft.java.test.runner.jar") then
				table.insert(bundles, bundle)
			end
		end
	end


	local extendedClientCapabilities = require('jdtls').extendedClientCapabilities
	extendedClientCapabilities.resolveAdditionalTextEditsSupport = true
	config.init_options = {
		extendedClientCapabilities = extendedClientCapabilities,
		bundles = bundles
	}

	local finders = require('telescope.finders')
	local sorters = require('telescope.sorters')
	local actions = require('telescope.actions')
	local pickers = require('telescope.pickers')

	require('jdtls.ui').pick_one_async = function(items, prompt, label_fn, cb)
		local opts = {}
		pickers.new(opts, {
			prompt_title = prompt,
			finder = finders.new_table {
				results = items,
				entry_maker = function(entry)
					return {
						value = entry,
						display = label_fn(entry),
						ordinal = label_fn(entry),
					}
				end,
			},
			sorter = sorters.get_generic_fuzzy_sorter(),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					local selection = actions.get_selected_entry()
					actions.close(prompt_bufnr)

					cb(selection.value)
				end)
				return true
			end,
		}):find()
	end
	require('jdtls').start_or_attach(config)
end

return M
