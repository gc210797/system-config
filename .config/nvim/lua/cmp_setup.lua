local M = {}

local function has_words_before()
	if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
		return false
	end
	local line, col = unpack(vim.api.nvim_win_get_cursor(0))
	return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local function feedkey(key)
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), "n", true)
end

function M.setup()
	local cmp = require("cmp")
	local luasnip = require("luasnip")
	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end
		},
		mapping = {
			['<Tab>'] = cmp.mapping(function(fallback)
				if vim.fn.pumvisible() == 1 then
					feedkey("<C-n>")
				elseif luasnip.expand_or_jumpable() then
					luasnip.expand_or_jump()
				elseif has_words_before() then
					cmp.complete()
				else
					fallback()
				end
			end, {"i", "s"}),
			['<S-Tab>'] = cmp.mapping(function(fallback)
				if vim.fn.pumvisible() == 1 then
					feedkey("<C-p>")
				elseif luasnip.jumpable(-1) then
					luasnip.jump(-1)
				else
					fallback()
				end
			end, {"i", "s"}),
			['<C-d>'] = cmp.mapping.scroll_docs(-4),
			['<C-f>'] = cmp.mapping.scroll_docs(4),
			['<CR>'] = cmp.mapping.confirm({select = true})
		},
		sources = {
			{name = 'nvim_lsp'},
			{name = 'luasnip'},
			{name = 'buffer'},
			{name = 'crates'},
			{name = 'orgmode'}
		}
	})
end

return M
