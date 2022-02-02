local M = {}

local namespace = vim.api.nvim_create_namespace("rust-analyzer/inlayHints")

local function codelldb_setup()
	local dap = require('dap')
	dap.set_log_level('TRACE')
	dap.adapters.codelldb = function(on_adapter)
	  local stdout = vim.loop.new_pipe(false)
	  local stderr = vim.loop.new_pipe(false)
	  local cmd = os.getenv('HOME') .. '/dap/codelldb-x86_64-linux/adapter/codelldb'
	  local handle, pid_or_err
	  local opts = {
	    stdio = {nil, stdout, stderr},
	    args = {"--liblldb", os.getenv('HOME') .. '/dap/codelldb-x86_64-linux/lldb/lib/liblldb.so'},
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

local function parse_inlay_hints(result)
	local map = {}

	if type(result) ~= "table" then return {} end

	for _, value in pairs(result) do
		local line = tostring(value.range["end"].line)
		local label = value.label
		local kind = value.kind

		if map[line] ~= nil then
			table.insert(map[line], {label = label, kind = kind})
		else
			map[line] = {{label = label, kind = kind}}
		end

	end

	return map
end


local function disable_inlay_hints()
	vim.api.nvim_buf_clear_namespace(0, namespace, 0, -1)
end

local function inlay_hints_handler(err, result, ctx)
	if err then return end

	local bufnr = ctx.bufnr

	if (vim.api.nvim_get_current_buf() ~= bufnr) then return end

	disable_inlay_hints()

	local ret = parse_inlay_hints(result)

	local max_len = -1

	for key, _ in pairs(ret) do
		local line = tonumber(key)
		local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]

		if current_line then
			local current_line_len = string.len(current_line)
			max_len = math.max(max_len, current_line_len)
		end
	end

	for key, value in pairs(ret) do
		local virt_text = ""
		local line = tonumber(key)

		local current_line = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]

		if current_line then
			local param_hints = {}
			local other_hints = {}

			for _, value_inner in ipairs(value) do
				if value_inner.kind == "ParameterHint" then
					table.insert(param_hints, value_inner.label)
				else
					table.insert(other_hints, value_inner.label)
				end
			end

			if not vim.tbl_isempty(param_hints) then
				virt_text = virt_text .. "<- " .. "("
				for i, value_inner_inner in ipairs(param_hints) do
					virt_text = virt_text .. value_inner_inner

					if i ~= #param_hints then
						virt_text = virt_text .. ", "
					end
				end

				virt_text = virt_text .. ") "
			end

			if not vim.tbl_isempty(other_hints) then
				virt_text = virt_text .. "=> "
				for i, value_inner_inner in ipairs(other_hints) do
					virt_text = virt_text .. value_inner_inner
					if i ~= #other_hints then
						virt_text = virt_text .. ", "
					end
				end
			end


			vim.api.nvim_buf_set_extmark(bufnr, namespace, line, 0, {
				virt_text_pos = "eol",
				virt_text = {
					{virt_text, "Comment"}
				},
				hl_mode = "combine"
			})
		end
	end
end

local function get_params()
	return {textDocument = vim.lsp.util.make_text_document_params()}
end

function M.inlay_hints()
	require("commons").lsp_request(0, "rust-analyzer/inlayHints", get_params(), inlay_hints_handler)
end


function M.setup()
	vim.g["rustfmt_autosave"] = 1


	vim.api.nvim_command('augroup Crates')
	vim.api.nvim_command('autocmd BufRead Cargo.toml :lua require("crates").setup()')
	vim.api.nvim_command('augroup END')


	local on_attach = function(client, bufnr)
		require("lsp-status").register_progress()
		require("lsp-status").on_attach(client)
	 	require("commons").common_bindings(bufnr, {noremap = true, silent = false})

		local events = "BufEnter,BufWinEnter,TabEnter,BufWritePost"

		vim.api.nvim_command('augroup InlayHints')
		vim.api.nvim_command('autocmd ' .. events .. ' *.rs :lua require("rust_setup").inlay_hints()')
		vim.api.nvim_command('augroup END')
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
