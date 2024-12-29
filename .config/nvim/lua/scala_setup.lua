local M = {}

function M.setup()
    local opts = function ()
        local metals_config = require("metals").bare_config()

        metals_config.settings = {
          showImplicitArguments = true,
          excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
          inlayHints = {
               hintsInPatternMatch = { enable = false },
               implicitArguments = { enable = false },
               implicitConversions = { enable = false },
               inferredTypes = { enable = false },
               typeParameters = { enable = false },
            }
        }

        metals_config.init_options.statusBarProvider = "off"
        local Path = require("plenary.path")
        metals_config.find_root_dir = function(patterns, startpath)
            local root_dir = nil
            local path = Path:new(startpath)
            for _, parent in ipairs(path:parents()) do
                for _, pattern in ipairs(patterns) do
                    local target = Path:new(parent, pattern)
                    if target:exists() then
                        root_dir = parent
                    end
                end
            end
            return root_dir
        end

        metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

        metals_config.on_attach = function(client, bufnr)
            local commons = require("commons")
            commons.common_bindings(bufnr, {noremap = true, silent = false})
            require("metals").setup_dap()
        end

        vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }
        return metals_config
    end

    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", {clear = true})
    vim.api.nvim_create_autocmd("FileType", {
        pattern = {"scala", "sbt"},
        callback = function()
            require("metals").initialize_or_attach(opts())
        end,
        group = nvim_metals_group,
    })
end

return M
