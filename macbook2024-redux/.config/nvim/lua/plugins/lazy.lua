return {
  {
    "xero/miasma.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd([[colorscheme miasma]])
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    version = "0.1.8",
    dependencies = {
      {"nvim-lua/plenary.nvim"}
    }
  },

  {
	  "nvim-treesitter/nvim-treesitter",
	  build = ":TSUpdate"
  },

  { "nvim-lua/plenary.nvim", lazy = true },

  {
	  "ThePrimeagen/harpoon",
	  branch = "harpoon2",
	  dependencies = {
      {"nvim-lua/plenary.nvim"}
    }
  },

  { "mbbill/undotree" },
  { "tpope/vim-fugitive" },
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-cmdline" },
  { "saadparwaiz1/cmp_luasnip" },
  { "neovim/nvim-lspconfig" },
  { "L3MON4D3/LuaSnip" },
  { "stevearc/overseer.nvim",
    opts = {},
  },
  {
    "samir-roy/code-bridge.nvim",
    config = function()
      require('code-bridge').setup()
    end
  }

}
