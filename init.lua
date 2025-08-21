-- Bootstrap lazy.nvim (this downloads it automatically)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
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
vim.cmd.colorscheme("habamax")

-- Clipboard integration
vim.opt.clipboard = "unnamedplus" -- Use system clipboard for all yank/paste operations

-- Highlight yanked text
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Easy window navigation (optional - uncomment if you want these)
vim.keymap.set("n", "<C-h>", "<C-w>h") -- Ctrl+h to go left
vim.keymap.set("n", "<C-l>", "<C-w>l") -- Ctrl+l to go right
vim.keymap.set("n", "<C-j>", "<C-w>j") -- Ctrl+j to go down
vim.keymap.set("n", "<C-k>", "<C-w>k") -- Ctrl+k to go up

-- Map Escape to clear search highlighting
vim.keymap.set("n", "<Esc>", ":noh<CR><Esc>", { silent = true })

-- Setup plugins
require("lazy").setup({
	{
		"nvim-tree/nvim-tree.lua",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			-- Disable netrw (built-in file explorer)
			vim.g.loaded_netrw = 1
			vim.g.loaded_netrwPlugin = 1

			require("nvim-tree").setup({
				update_cwd = true,
				view = { width = 50 },
				filters = { dotfiles = false },
				actions = { open_file = { quit_on_open = false } },
				git = { enable = true, ignore = false, show_on_dirs = true },
				renderer = { icons = { git_placement = "before", show = { git = true } } },
			})

			-- Keybind to toggle file tree
			vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = function()
			require("nvim-treesitter.configs").setup({
				-- Install parsers for these languages
				ensure_installed = {
					"sql",
					"python",
					"yaml",
					"json",
					"toml",
					"markdown",
					"bash",
					"lua",
					"dockerfile",
					"gitignore",
					"jinja",
					"jinja_inline",
				},

				-- Install parsers synchronously (only applied to `ensure_installed`)
				sync_install = false,

				-- Automatically install missing parsers when entering buffer
				auto_install = true,

				highlight = {
					enable = true,
					-- Setting this to true will run `:h syntax` and tree-sitter at the same time.
					additional_vim_regex_highlighting = false,
				},
			})
		end,
	},
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
			-- Fuzzy file finder (like VSCode Cmd+P)
			vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
			vim.keymap.set("n", "<leader>fg", ":Telescope live_grep<CR>")
			vim.keymap.set("n", "<leader>fb", ":Telescope buffers<CR>")
			vim.keymap.set("n", "<leader>fh", ":Telescope help_tags<CR>")

			-- Make Cmd+P work like VSCode (since leader is space, use space+p for now)
			vim.keymap.set("n", "<leader>p", ":Telescope find_files<CR>")
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		config = function()
			require("gitsigns").setup({
				signs = {
					add = { text = "│" },
					change = { text = "│" },
					delete = { text = "_" },
					topdelete = { text = "‾" },
					changedelete = { text = "~" },
					untracked = { text = "┆" },
				},
			})
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		config = function()
			require("lualine").setup({
				options = {
					theme = "auto",
					section_separators = "",
					component_separators = "|",
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = { "encoding", "fileformat", "filetype" },
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},
	{
		"PedramNavid/dbtpal",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
		},
		ft = {
			"sql",
			"md",
			"yaml",
		},
		keys = {
			{ "<leader>drf", "<cmd>DbtRun<cr>" },
			{ "<leader>drp", "<cmd>DbtRunAll<cr>" },
			{ "<leader>dtf", "<cmd>DbtTest<cr>" },
			{ "<leader>dm", "<cmd>lua require('dbtpal.telescope').dbt_picker()<cr>" },
		},
		config = function()
			require("dbtpal").setup({
				path_to_dbt = "dbt",
				path_to_dbt_project = "",
				path_to_dbt_profiles_dir = vim.fn.expand("~/.dbt"),
				include_profiles_dir = true,
				include_project_dir = true,
				include_log_level = true,
				extended_path_search = true,
				protect_compiled_files = true,
				pre_cmd_args = {},
				post_cmd_args = {},
			})
			require("telescope").load_extension("dbtpal")
		end,
	},
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				-- Customize or remove this keymap to your liking
				"<leader>f",
				function()
					require("conform").format({ async = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		-- This will provide type hinting with LuaLS
		---@module "conform"
		---@type conform.setupOpts
		opts = {
			-- Define your formatters
			formatters_by_ft = {
				lua = { "stylua" },
				python = { "black" },
				sql = { "sqlfmt" },
				yml = { "yamlfmt" },
				yaml = { "yamlfmt" },
			},
			-- Set default options
			default_format_opts = {
				lsp_format = "fallback",
			},
			-- Set up format-on-save
			-- format_on_save = { timeout_ms = 500 },
			-- Customize formatters
			-- formatters = {
			--   shfmt = {
			--     prepend_args = { "-i", "2" },
			--   },
			-- },
		},
		init = function()
			-- If you want the formatexpr, here is the place to set it
			vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
		end,
	},
})
