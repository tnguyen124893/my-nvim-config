-- Bootstrap lazy.nvim (this downloads it automatically)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
    })
end
vim.opt.rtp:prepend(lazypath)

-- Basic Neovim settings
vim.opt.number = true -- Show line numbers
vim.opt.relativenumber = true -- Show relative line numbers
vim.g.mapleader = " " -- Set space as leader key

-- Tab and indentation
vim.opt.tabstop = 4 -- Number of spaces tabs count for
vim.opt.shiftwidth = 4 -- Size of an indent
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.autoindent = true -- Copy indent from current line
vim.opt.smartindent = true -- Make indenting smarter

-- Set colorscheme
vim.cmd.colorscheme "slate"

-- Clipboard integration
vim.opt.clipboard = "unnamedplus"  -- Use system clipboard for all yank/paste operations

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Easy window navigation (optional - uncomment if you want these)
vim.keymap.set('n', '<C-h>', '<C-w>h') -- Ctrl+h to go left
vim.keymap.set('n', '<C-l>', '<C-w>l') -- Ctrl+l to go right
vim.keymap.set('n', '<C-j>', '<C-w>j') -- Ctrl+j to go down
vim.keymap.set('n', '<C-k>', '<C-w>k') -- Ctrl+k to go up

-- Setup plugins
require("lazy").setup({
    {
        "nvim-tree/nvim-tree.lua",
        dependencies = {"nvim-tree/nvim-web-devicons"},
        config = function()
            -- Disable netrw (built-in file explorer)
            vim.g.loaded_netrw = 1
            vim.g.loaded_netrwPlugin = 1

            require("nvim-tree").setup({
                update_cwd = true,
                view = {width = 50},
                filters = {dotfiles = false},
                actions = {open_file = {quit_on_open = false}},
                git = {enable = true, ignore = false}
            })

            -- Keybind to toggle file tree
            vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>')
        end
    }, {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter.configs").setup({
                -- Install parsers for these languages
                ensure_installed = {
                    "sql", "python", "yaml", "json", "toml", "markdown", "bash",
                    "lua", "dockerfile", "gitignore", "jinja", "jinja_inline"
                },

                -- Install parsers synchronously (only applied to `ensure_installed`)
                sync_install = false,

                -- Automatically install missing parsers when entering buffer
                auto_install = true,

                highlight = {
                    enable = true,
                    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
                    additional_vim_regex_highlighting = false
                }
            })
        end
    }, {
        "nvim-telescope/telescope.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
          -- Fuzzy file finder (like VSCode Cmd+P)
          vim.keymap.set('n', '<leader>ff', ':Telescope find_files<CR>')
          vim.keymap.set('n', '<leader>fg', ':Telescope live_grep<CR>')
          vim.keymap.set('n', '<leader>fb', ':Telescope buffers<CR>')
          vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<CR>')
          
          -- Make Cmd+P work like VSCode (since leader is space, use space+p for now)
          vim.keymap.set('n', '<leader>p', ':Telescope find_files<CR>')
        end,
    }
})
