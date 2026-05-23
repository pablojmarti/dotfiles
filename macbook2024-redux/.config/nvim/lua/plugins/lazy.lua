return {
  {
    "nvim-telescope/telescope.nvim",
    version = "0.1.8",
    dependencies = {
      {"nvim-lua/plenary.nvim"}
    }
  },


  { "nvim-lua/plenary.nvim", lazy = true },

  {
	  "ThePrimeagen/harpoon",
	  branch = "harpoon2",
	  dependencies = {
      {"nvim-lua/plenary.nvim"}
    }
  },

  { "neovim/nvim-lspconfig" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "hrsh7th/cmp-cmdline" },
  { "hrsh7th/nvim-cmp" },

  { "mbbill/undotree" },
  { "tpope/vim-fugitive" },
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  { "saadparwaiz1/cmp_luasnip" },
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
