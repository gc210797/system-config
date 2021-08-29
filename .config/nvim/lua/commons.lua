local M = {};

function M.smart_tab()
	return vim.fn.pumvisible() == 1 and [[\<C-n>]] or [[\<Tab>]]
end
