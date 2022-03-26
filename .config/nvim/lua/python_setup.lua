local M = {}
local api = vim.api
local sessions = {}
M.widgets = {}
M.widgets.sessions = {
  refresh_listener = 'event_initialized',
  new_buf = function()
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'buftype', 'nofile')
    api.nvim_buf_set_keymap(
      buf, "n", "<CR>", "<Cmd>lua require('dap.ui').trigger_actions()<CR>", {})
    api.nvim_buf_set_keymap(
      buf, "n", "<2-LeftMouse>", "<Cmd>lua require('dap.ui').trigger_actions()<CR>", {})
    return buf
  end,
  render = function(view)
    local layer = view.layer()
    local render_session = function(session)
      local dap = require('dap')
      local suffix
      if session.current_frame then
        suffix = 'Stopped at line ' .. session.current_frame.line
      elseif session.stopped_thread_id then
        suffix = 'Stopped'
      else
        suffix = 'Running'
      end
      local prefix = session == dap.session() and '→ ' or '  '
      return prefix .. (session.config.name or 'No name') .. ' (' .. suffix .. ')'
    end
    local context = {}
    context.actions = {
      {
        label = 'Activate session',
        fn = function(_, session)
          if session then
            require('dap').set_session(session)
            if vim.bo.bufhidden == 'wipe' then
              view.close()
            else
              view.refresh()
            end
          end
        end
      }
    }
    layer.render(vim.tbl_keys(sessions), render_session, context)
  end
}

function M.setup()
	local on_attach = function(client, bufnr)
		local opts = {noremap = true, silent = false}
		local commons = require("commons")
		require("lsp-status").register_progress()
		require("lsp-status").on_attach(client)
	 	commons.common_bindings(bufnr, opts)
		commons.buf_set_keymap(bufnr, "<leader>di", "<cmd>PyrightOrganizeImports<CR>", opts)
		commons.buf_set_keymap(bufnr, "<leader>dm", "<cmd>lua require('dap-python').test_method()<CR>", opts)
		commons.buf_set_keymap(bufnr, "<leader>dc", "<cmd>lua require('dap-python').test_class()<CR>", opts)

		vim.cmd([[
			augroup auto_format
			autocmd!
			autocmd BufWritePost *.py lua vim.lsp.buf.formatting_sync()
			augroup end
		]])
		require('dap-python').setup("~/dap/debugpy/bin/python")
		require('dap-python').test_runner = 'pytest'
	end

	local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
	capabilities = vim.tbl_extend('keep', capabilities, require("lsp-status").capabilities)
	capabilities.textDocument.completion.completionItem.snippetSupport = true

	require("lspconfig").pyright.setup{
		on_attach = on_attach,
		capabilities = capabilities,
		settings = {
			python = {
				analysis = {
					typeCheckingMode = "strict",
					diagnosticMode = "workspace"
				}
			}
		}

	}

	--null-ls setup for pytlint and autopep8
	local null_ls = require("null-ls")
	local sources = {
		null_ls.builtins.diagnostics.pylint.with({
			method = null_ls.methods.DIAGNOSTICS_ON_SAVE
		}),
		null_ls.builtins.formatting.autopep8
	}

	null_ls.register(sources)
end

function M.debug_superset()
	local dap = require("dap")
	local host = "127.0.0.1"
	local port = 5678

	local pythonAttachAdapter = {
		type = "server",
		host = host,
		port = port
	}

	local pythonAttachConfig = {
		type = "python",
		request = "attach",
		connect = {
			port = port
		},
		node = "remote",
		name = "Superset Debugger",
		cwd = vim.fn.getcwd(),
		pathMappings = {
			{
				localRoot = vim.fn.getcwd(),
				remoteRoot = "/app"
			}
		},
		justMyCode = false
	}


	dap.listeners.after["event_debugpyAttach"]["dap-python"] = function(_, config)
		print(vim.inspect(config.connect))
		Session = require("dap.session"):connect(config.connect, {}, function(err)
			assert(not err, vim.inspect(err))
			Session:initialize(config, pythonAttachAdapter)
			sessions[Session] = true
		end)
	end

	dap.listeners.after.event_initialized['dap-python'] = function(session)
		sessions[session] = true
		require('dap.ui.widgets').sidebar(M.widgets.sessions).open()
	end

	local remove_session = function(session)
		sessions[session] = true
	end

	dap.listeners.after.event_exited['dap-python'] = remove_session
	dap.listeners.after.event_terminated['dap-python'] = remove_session

	local session = dap.attach(pythonAttachAdapter, pythonAttachConfig)
	if session == nil then
		io.write("Error launching adapter")
	end
	dap.repl.open()
end

return M
