-- Core Options (Adding Indentation Settings)
-- Setting indentation to 4 spaces
vim.opt.tabstop = 4         -- A hard tab character displays as 4 spaces
vim.opt.shiftwidth = 4      -- Auto-indentation is 4 spaces
vim.opt.expandtab = true    -- Insert spaces instead of a tab character
vim.opt.smartindent = true  -- Enable smart auto-indenting

-- Leader key
vim.g.mapleader = " "

-- Line numbers
vim.opt.number = true
vim.opt.relativenumber = true

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  "nvim-lua/plenary.nvim",
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  {
    "neovim/nvim-lspconfig",
  },
  {
    "kevinhwang91/nvim-ufo",
    dependencies = "kevinhwang91/promise-async",
    config = function()
      vim.o.foldcolumn = "1"
      vim.o.foldlevel = 99
      vim.o.foldlevelstart = 99
      vim.o.foldenable = true

      require("ufo").setup()

      vim.keymap.set("n", "zR", require("ufo").openAllFolds)
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require'nvim-treesitter.configs'.setup {
        ensure_installed = { "c", "cpp", "lua", "python", "javascript", "typescript" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<c-space>",
            node_incremental = "<c-space>",
            scope_incremental = "<c-s>",
            node_decremental = "<c-backspace>",
          },
        },

      }
    end,
  },

  "nvim-treesitter/nvim-treesitter-context",
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    opts = {}
  },
  {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup()
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
    },
  },
})

-- Load LSP configuration
require("lsp")

-- Telescope
vim.keymap.set("n", "<leader>ff", require("telescope.builtin").find_files, {})

-- Load the colorscheme module now that it's in the runtime path
vim.cmd.colorscheme("elaina")

-- Map <Leader>y to copy (yank) to the system clipboard
vim.keymap.set({"n", "v"}, "<leader>y", '"+y', {desc = "Yank to system clipboard"})
-- Map <Leader>d to cut (delete/yank) to the system clipboard
vim.keymap.set({"n", "v"}, "<leader>d", '"+d', {desc = "Cut to system clipboard"})
-- Map <Leader>p to paste from the system clipboard
vim.keymap.set({"n", "v"}, "<leader>p", '"+p', {desc = "Paste from system clipboard"})
