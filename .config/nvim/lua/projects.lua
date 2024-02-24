local M = {}

function M.setup()
    vim.opt.sessionoptions:append("globals")
    require('nvim-tree').setup({
        renderer = {
            group_empty = true
        },
        view = {
            adaptive_size = true
        },
        respect_buf_cwd = true
    })
    require("neovim-project").setup {
        projects = {
            "~/work/*",
            "~/.config/*"
        },
        last_session_on_startup = false
    }
    vim.keymap.set('n', '<leader>p', '<cmd>Telescope neovim-project discover<cr>', {})
    vim.keymap.set('n', '<leader>P', '<cmd>Telescope neovim-project history<cr>', {})
end

return M
