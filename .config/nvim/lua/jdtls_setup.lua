local M = {}

function M.setup()
	local on_attach = function(client, buffer)
		require('jdtls.setup').add_commands()
		require('lsp-status').register_progress()
		require('jdtls').setup_dap({ hotcodereplace = 'auto' })

		local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(buffer, 'n', ...) end
		local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

		buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

		local opts = {noremap = true, silent = true}

		buf_set_keymap('[g', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
		buf_set_keymap(']g', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
		buf_set_keymap('gd', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
		buf_set_keymap('gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)

		buf_set_keymap('gy', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
		
		buf_set_keymap('gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
		
		buf_set_keymap('<leader>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)

		buf_set_keymap('K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
		buf_set_keymap('rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
		buf_set_keymap('ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

		buf_set_keymap('<leader>di', "<cmd>lua require('jdtls').organize_imports()<CR>", opts)
		buf_set_keymap('<leader>dt', "<cmd>lua require('jdtls').test_class()<CR>", opts)
		buf_set_keymap('<leader>dn', "<cmd>lua require('jdtls').test_nearest_method()<CR>", opts)
		buf_set_keymap('<leader>de', "<cmd>lua require('jdtls').extract_variable()<CR>", opts)
		buf_set_keymap('<leader>df', "<cmd>lua require('jdtls').test_class()<CR>", opts)
		buf_set_keymap('<leader>dn', "<cmd>lua require('jdtls').test_nearest_method()<CR>", opts)

		buf_set_keymap('<C-f>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(1)<CR>", opts)
		buf_set_keymap('<C-b>', "<cmd>lua require('lspsaga.action').smart_scroll_with_saga(-1)<CR>", opts)

		require('formatter').setup {
			filetype = {
				java = {
					function()
						return {
							exe = 'java',
							args = {'-jar', os.getenv('HOME') .. '/jdtls/google-java-format.jar', vim.api.nvim_buf_get_name(0)},
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

		require('completion').on_attach(client)
	end

	local root_markers = {'pom.xml', 'gradle.build'}
	local root_dir = require('jdtls.setup').find_root(root_markers)
	local home = os.getenv('HOME')

	local capabilities = {
		workspace = {
			configuration = true
		},
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = true
				}
			}
		}
	}

	local workspace_folder = home .. '/workspace/' .. vim.fn.fnamemodify('root_dir', ':p:h:t')
	local config = {
		flags = {
			allow_incremental_sync = true
		},
		capabilities = capabilities
	}

	config.settings = {
		['java.format.settings.url'] = home .. '/jdtls/java-google-formatter.xml',
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

	config.cmd = {home .. '/jdtls/jdtls.sh', workspace_folder}
	config.on_attach = on_attach
	config.on_init = function(client, _)
		client.notify('workspace/didChangeConfiguration', {settings = config.settings})
	end

	-- local bundles = {
	-- 	vim.fn.glob(home .. "/jdtls/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar")
	-- }
	
	bundles = {}

	local jar_patterns = {
		"/jdtls/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar",
		"/jdtls/vscode-java-test/server/*.jar"
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
				actions.goto_file_selection_edit:replace(function()
					local selection = actions.get_selected_entry(prompt_bufnr)
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
