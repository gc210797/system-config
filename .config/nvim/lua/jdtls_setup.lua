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
		commons.buf_set_keymap(buffer, '<leader>dc', "<cmd>lua require('jdtls').test_class()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>dm', "<cmd>lua require('jdtls').test_nearest_method()<CR>", opts)
		commons.buf_set_keymap(buffer, '<leader>de', "<cmd>lua require('jdtls').extract_variable()<CR>", opts)

		vim.api.nvim_exec([[
			augroup FormatJavaAuGroup
				autocmd!
				autocmd BufWritePost *.java lua vim.lsp.buf.formatting()
				autocmd BufWritePost *.java lua require('jdtls.dap').setup_dap_main_class_configs()
				autocmd BufWritePost *.java JdtUpdateConfig
			augroup end
			hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
			hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
			hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
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
        "/test/vscode-java-test/java-extension/com.microsoft.java.test.plugin/target/*.jar",
        "/test/vscode-java-test/java-extension/com.microsoft.java.test.runner/target/*.jar",
        "/test/vscode-java-test/java-extension/com.microsoft.java.test.runner/lib/*.jar"
	}

    local plugin_path = "/test/vscode-java-test/java-extension/com.microsoft.java.test.plugin.site/target/repository/plugins/"

    local bundle_list = vim.tbl_map(
        function(x) return require('jdtls.path').join(plugin_path, x) end,
        {
           'org.eclipse.jdt.junit4.runtime_*.jar',
           'org.eclipse.jdt.junit5.runtime_*.jar',
           'org.junit.jupiter.api*.jar',
           'org.junit.jupiter.engine*.jar',
           'org.junit.jupiter.migrationsupport*.jar',
           'org.junit.jupiter.params*.jar',
           'org.junit.vintage.engine*.jar',
           'org.opentest4j*.jar',
           'org.junit.platform.commons*.jar',
           'org.junit.platform.engine*.jar',
           'org.junit.platform.launcher*.jar',
           'org.junit.platform.runner*.jar',
           'org.junit.platform.suite.api*.jar',
           'org.apiguardian*.jar'
        }
    )

    vim.list_extend(jar_patterns, bundle_list)

	for _, jar_pattern in ipairs(jar_patterns) do
		for _, bundle in ipairs(vim.split(vim.fn.glob(home .. jar_pattern), '\n')) do
            if not vim.endswith(bundle, "com.microsoft.java.test.runner-jar-with-dependencies.jar")
               and not vim.endswith(bundle, "com.microsoft.java.test.runner.jar") then
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

    local finders = require("telescope.finders")
    local sorters = require("telescope.sorters")
    local actions = require("telescope.actions")
    local pickers = require("telescope.pickers")

    require("jdtls.ui").pick_one_async = function(items, prompt, label_fn, cb)
        local opts = {}
        pickers.new(opts, {
            prompt_title = prompt,
            finder = finders.new_table {
                results = items,
                entry_maker = function(entry)
                    return {
                        value = entry,
                        display = label_fn(entry),
                        ordinal = label_fn(entry)
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
            end
        })
    end

	require('jdtls').start_or_attach(config)
end

return M
