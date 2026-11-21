return {
  { 
    "HiPhish/rainbow-delimiters.nvim"
  },
  {
    "oskarnurm/koda.nvim",
    lazy = false, -- make sure we load this during startup if it is your main colorscheme
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      -- require("koda").setup({ transparent = true })
      vim.cmd("colorscheme koda-moss")
    end,
  },
  {
    "axsaucedo/neovim-power-mode",
    config = function()
      require("power-mode").setup({
        particles = { preset = "disintegrate" },
        shake = { mode = "none" },
        combo = {
          position = "bottom-right",
        },
        fire_wall = {
          enabled = true,         -- true | false
          bottom_offset = 2,       -- rows to skip at bottom (statusline/cmdline)
          max_rows = 5,            -- maximum fire height in rows
        },
      })
    end,
  },
  {
    "saxon1964/neovim-tips",
    version = "*", -- Only update on tagged releases
    lazy = false,  -- Load on startup for daily tip
    dependencies = {
      "MunifTanjim/nui.nvim",
      -- OPTIONAL: Choose your preferred markdown renderer (or omit for raw markdown)
      "MeanderingProgrammer/render-markdown.nvim", -- Clean rendering
      -- OR: "OXY2DEV/markview.nvim", -- Rich rendering with advanced features
    },
    opts = {
      -- OPTIONAL: Daily tip mode (default: 1)
      daily_tip = 1,  -- 0 = off, 1 = once per day, 2 = every startup
      -- OPTIONAL: Bookmark symbol (default: "🌟 ")
      bookmark_symbol = "🌟 ",
    },
    init = function()
      -- OPTIONAL: Change to your liking or drop completely
      -- The plugin does not provide default key mappings, only commands
      local map = vim.keymap.set
      map("n", "<leader>nto", ":NeovimTips<CR>", { desc = "Neovim tips", silent = true })
      map("n", "<leader>ntb", ":NeovimTipsBookmarks<CR>", { desc = "Bookmarked tips", silent = true })
      map("n", "<leader>nte", ":NeovimTipsEdit<CR>", { desc = "Edit your Neovim tips", silent = true })
      map("n", "<leader>nta", ":NeovimTipsAdd<CR>", { desc = "Add your Neovim tip", silent = true })
      map("n", "<leader>nth", ":help neovim-tips<CR>", { desc = "Neovim tips help", silent = true })
      map("n", "<leader>ntr", ":NeovimTipsRandom<CR>", { desc = "Show random tip", silent = true })
      map("n", "<leader>ntp", ":NeovimTipsPdf<CR>", { desc = "Open Neovim tips PDF", silent = true })
    end
  },
  {
    "sphamba/smear-cursor.nvim",
    opts = {},
  },
  {'akinsho/toggleterm.nvim', version = "*", config = true},
  {
    "nvim-lualine/lualine.nvim",
    optional = true,
    event = "VeryLazy",
    opts = function(_, opts)
      table.insert(opts.sections.lualine_x, 3, {
        function()
          return require("pomodoro").get_pomodoro_status("🍅❌","🍅","☕")
        end,
      })
    end,
  },
  -- lazy.nvim
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    opts = {
      -- add any options here
    },
    dependencies = {
      -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      "rcarriga/nvim-notify",
    }
  },
  {
    'nvimdev/dashboard-nvim',
    event = 'VimEnter',
    config = function()
      require('dashboard').setup {
        config = {
          theme = 'doom',
        }
      }
    end,
    dependencies = { {'nvim-tree/nvim-web-devicons'}}
  },
  --[[
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    build = "make",
    version = false,
    opts = {
      provider = "hermes",
      model = "Qwen3.6-35B-A3B-8bit",
      auto_suggest = false,
      allow_provider_prompt = true,
      auto_apply_diff_after_generation = false,
      auto_approve_tool_permissions = false,
      window = {
        position = "smart",
        layout = "vertical",
        width = 60,
        height = 60,
        sidebar_header = {
          align = "center",
          rounded = true,
          include_model = true,
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
  ]]
  {
    "nvim-telescope/telescope.nvim",
    version = '*',
    dependencies = {
      {"nvim-lua/plenary.nvim"},
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },

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

  -- File tree 
  {
    "nvim-tree/nvim-tree.lua"
  },

  -- Syntax highlighting is back baby
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate"
  },
  -- Undotree! 
  -- I need to learn how to use this better
  { "mbbill/undotree" },

  -- Git commands via : 
  { "tpope/vim-fugitive" },

  -- Nvim default lsp configuration
  { "neovim/nvim-lspconfig" },

  -- Package Manager for Neovim! 
  -- Used for most LSP setups
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },


  -- NVIM Autocompletion
  -- NEEDS REVIEW
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-cmdline" },
  { "saadparwaiz1/cmp_luasnip" },

  -- Lua Snippet engine
  -- NEEDS REVIEW
  { "L3MON4D3/LuaSnip" },
  -- Markdown renderer
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },            -- if you use the mini.nvim suite
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  -- Task Runner, originally installed for auto running C compiler
  {
    'stevearc/overseer.nvim',
    ---@module 'overseer'
    ---@type overseer.SetupOpts
    opts = {},
  },
  opts = {},
}
