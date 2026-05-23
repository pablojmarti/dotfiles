return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false,
    opts = {
      provider = "hermes",
      auto_suggest = false,
      allow_provider_prompt = true,
      window = {
        layout = "vertical",
        width = 0.6,
        sidebar_header = {
          align = "center",
          rounded = true,
        },
      },
      mode = "agentic",
      acp_providers = {
        ["hermes"] = {
          command = "hermes",
          args = { "acp", "--profile", "code" },
        }
      }
    },
    dependencies = {
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "stevearc/dressing.nvim",
      "nvim-tree/nvim-web-devicons"
    },
  },
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
}
