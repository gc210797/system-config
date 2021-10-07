local M = {}

local function codelldb_setup()
	local dap = require('dap')
	dap.set_log_level('TRACE')
	dap.adapters.codelldb = function(on_adapter)
	  local stdout = vim.loop.new_pipe(false)
	  local stderr = vim.loop.new_pipe(false)
	  local cmd = os.getenv('HOME') .. '/dap/codelldb-x86_64-linux/extension/adapter/codelldb'
	  local handle, pid_or_err
	  local opts = {
	    stdio = {nil, stdout, stderr},
	    args = {"--liblldb", os.getenv('HOME') .. '/dap/codelldb-x86_64-linux/extension/lldb/lib/liblldb.so'},
	    detached = true,
	  }
	  handle, pid_or_err = vim.loop.spawn(cmd, opts, function(code)
	    stdout:close()
	    stderr:close()
	    handle:close()
	    if code ~= 0 then
	      print("codelldb exited with code", code)
	    end
	  end)
	  assert(handle, "Error running codelldb: " .. tostring(pid_or_err))
	  stdout:read_start(function(err, chunk)
	    assert(not err, err)
	    if chunk then
	      local port = chunk:match('Listening on port (%d+)')
	      if port then
	        vim.schedule(function()
	          on_adapter({
	            type = 'server',
	            host = '127.0.0.1',
	            port = port
	          })
	        end)
	      else
	        vim.schedule(function()
	          require("dap.repl").append(chunk)
	        end)
	      end
	    end
	  end)
	  stderr:read_start(function(err, chunk)
	    assert(not err, err)
	    if chunk then
	      vim.schedule(function()
	        require("dap.repl").append(chunk)
	      end)
	    end
	  end)
	end

	dap.configurations.rust = {
	  {
	    name = "Launch file",
	    type = "codelldb",
	    request = "launch",
	    program = function()
	      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
	    end,
	    cwd = '${workspaceFolder}',
	    stopOnEntry = true,
	  },
	}
end

function M.setup()
	vim.g["rustfmt_autosave"] = 1
	vim.cmd([[
		autocmd CursorMoved,InsertLeave,BufEnter,BufWinEnter,TabEnter,BufWritePost *.rs :lua require('lsp_extensions').inlay_hints{ prefix = ' » ', highlight = "NonText", enabled = {"TypeHint", "ChainingHint", ParameterHint}}
	]])


	local on_attach = function(client, bufnr)
		require("lsp-status").register_progress()
		require("lsp-status").on_attach(client)
	 	require("commons").common_bindings(bufnr, {noremap = true, silent = false})
	end

	local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
	capabilities = vim.tbl_extend('keep', capabilities, require("lsp-status").capabilities)

	require('lspconfig').rust_analyzer.setup{
		on_attach = on_attach,
		flags = {
			debounce_text_changes = 150,
		},
		capabilities = capabilities
	}

	codelldb_setup()

end


return M
