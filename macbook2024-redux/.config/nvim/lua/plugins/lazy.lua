return {
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = false,
    opts = {
      mode = "agentic",
      provider = "hermes",
      acp_providers = {
        ['hermes'] = {
          command = 'hermes',
          args = { 'acp', '--profile', 'coding' },
        },
      }, 
      window = {
        layout = 'vertical',
        width = 0.6,
        sidebar_header = {
          align = 'center',
          rounded = true,
        },
      },
      auto_suggests = false,
      allow_provider_prompt = false,
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "stevearc/dressing.nvim",
      "folke/snacks.nvim",
      "nvim-tree/nvim-web-devicons",
      {
      -- support for image pasting
      "HakonHarnes/img-clip.nvim",
      event = "VeryLazy",
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
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
  {
    "samir-roy/code-bridge.nvim",
    config = function()
      require('code-bridge').setup()
    end
  }

}
