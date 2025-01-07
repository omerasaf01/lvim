-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

lvim.lsp.installer.setup.automatic_installation = false

-- C# için LSP ayarları
local lspconfig = require("lspconfig")


--
lvim.builtin.treesitter.autotag.enable = true;

lvim.builtin.which_key.mappings["t"] = {
  name = "+Terminal",
  f = { "<cmd>ToggleTerm<cr>", "Floating terminal" },
  v = { "<cmd>2ToggleTerm size=30 direction=vertical<cr>", "Split vertical" },
  h = { "<cmd>2ToggleTerm size=30 direction=horizontal<cr>", "Split horizontal" },
}

lvim.builtin.which_key.mappings["C"] = {
  name = "Copilot",
  c = { "<cmd>CopilotChat<cr>", "New Chat" },
}

lvim.builtin.which_key.mappings["B"] = {
  name = "DB Client",
  o = { "<cmd>lua require('dbee').open()<cr>", "Open DB Client" },
}

vim.g.copilot_no_tab_map = true
vim.api.nvim_set_keymap("i", "<C-a>", 'copilot#Accept("<CR>")', { silent = true, expr = true })


--})

--vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })




lvim.plugins = {
  -- lazy.nvim
  {
    "GustavEikaas/easy-dotnet.nvim",
    dependencies = { "nvim-lua/plenary.nvim", 'nvim-telescope/telescope.nvim', },
    config = function()
      local function get_secret_path(secret_guid)
        local path = ""
        local home_dir = vim.fn.expand('~')
        if require("easy-dotnet.extensions").isWindows() then
          local secret_path = home_dir ..
              '\\AppData\\Roaming\\Microsoft\\UserSecrets\\' .. secret_guid .. "\\secrets.json"
          path = secret_path
        else
          local secret_path = home_dir .. "/.microsoft/usersecrets/" .. secret_guid .. "/secrets.json"
          path = secret_path
        end
        return path
      end

      local dotnet = require("easy-dotnet")
      -- Options are not required
      dotnet.setup({
        --Optional function to return the path for the dotnet sdk (e.g C:/ProgramFiles/dotnet/sdk/8.0.0)
        -- easy-dotnet will resolve the path automatically if this argument is omitted, for a performance improvement you can add a function that returns a hardcoded string
        -- You should define this function to return a hardcoded path for a performance improvement 🚀
        get_sdk_path = get_sdk_path,
        ---@type TestRunnerOptions
        test_runner = {
          ---@type "split" | "float" | "buf"
          viewmode = "float",
          enable_buffer_test_execution = true, --Experimental, run tests directly from buffer
          noBuild = true,
          noRestore = true,
          icons = {
            passed = "",
            skipped = "",
            failed = "",
            success = "",
            reload = "",
            test = "",
            sln = "󰘐",
            project = "󰘐",
            dir = "",
            package = "",
          },
          mappings = {
            run_test_from_buffer = { lhs = "<leader>r", desc = "run test from buffer" },
            filter_failed_tests = { lhs = "<leader>fe", desc = "filter failed tests" },
            debug_test = { lhs = "<leader>d", desc = "debug test" },
            go_to_file = { lhs = "g", desc = "got to file" },
            run_all = { lhs = "<leader>R", desc = "run all tests" },
            run = { lhs = "<leader>r", desc = "run test" },
            peek_stacktrace = { lhs = "<leader>p", desc = "peek stacktrace of failed test" },
            expand = { lhs = "o", desc = "expand" },
            expand_node = { lhs = "E", desc = "expand node" },
            expand_all = { lhs = "-", desc = "expand all" },
            collapse_all = { lhs = "W", desc = "collapse all" },
            close = { lhs = "q", desc = "close testrunner" },
            refresh_testrunner = { lhs = "<C-r>", desc = "refresh testrunner" }
          },
          --- Optional table of extra args e.g "--blame crash"
          additional_args = {}
        },
        ---@param action "test" | "restore" | "build" | "run"
        terminal = function(path, action, args)
          local commands = {
            run = function()
              return string.format("dotnet run --project %s %s", path, args)
            end,
            test = function()
              return string.format("dotnet test %s %s", path, args)
            end,
            restore = function()
              return string.format("dotnet restore %s %s", path, args)
            end,
            build = function()
              return string.format("dotnet build %s %s", path, args)
            end
          }

          local command = commands[action]() .. "\r"
          vim.cmd("vsplit")
          vim.cmd("term " .. command)
        end,
        secrets = {
          path = get_secret_path
        },
        csproj_mappings = true,
        fsproj_mappings = true,
        auto_bootstrap_namespace = {
          --block_scoped, file_scoped
          type = "block_scoped",
          enabled = true
        },
      })

      -- Example command
      vim.api.nvim_create_user_command('Secrets', function()
        dotnet.secrets()
      end, {})

      -- Example keybinding
      vim.keymap.set("n", "<C-p>", function()
        dotnet.run_project()
      end)
    end
  },
  {
    'olivercederborg/poimandres.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('poimandres').setup {
        -- leave this setup function empty for default config
        -- or refer to the configuration section
        -- for configuration options
      }
    end,
  },
  {
    'linux-cultist/venv-selector.nvim',
    dependencies = { 'neovim/nvim-lspconfig', 'nvim-telescope/telescope.nvim', 'mfussenegger/nvim-dap-python' },
    opts = {
      -- Your options go here
      -- name = "venv",
      -- auto_refresh = false
    },
    event = 'VeryLazy', -- Optional: needed only if you want to type `:VenvSelect` without a keymapping
    keys = {
      -- Keymap to open VenvSelector to pick a venv.
      { '<leader>vs', '<cmd>VenvSelect<cr>' },
      -- Keymap to retrieve the venv from a cache (the one previously used for the same project directory).
      { '<leader>vc', '<cmd>VenvSelectCached<cr>' },
    },
  },
  { "folke/tokyonight.nvim" },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
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
    "aca/emmet-ls",
  },
  {
    "kndndrj/nvim-dbee",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    build = function()
      -- Install tries to automatically detect the install method.
      -- if it fails, try calling it with one of these parameters:
      --    "curl", "wget", "bitsadmin", "go"
      require("dbee").install()
    end,
    config = function()
      require("dbee").setup( --[[optional config]])
    end,
  },
  {
    "seblj/roslyn.nvim",
    ft = "cs",
    opts = {
      config = {
        settings = {
          ["csharp|inlay_hints"] = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            csharp_enable_inlay_hints_for_types = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_suppress_inlay_hints_for_parameters_that_differ_only_by_suffix = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true,
            dotnet_suppress_inlay_hints_for_parameters_that_match_method_intent = true,
          },
          ["csharp|code_lens"] = {
            dotnet_enable_references_code_lens = true,
          },
        },
      },
    }
  },
  {
    "windwp/nvim-ts-autotag",
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  {
    "github/copilot.vim",
    event = "VeryLazy",
    config = function()
      -- copilot assume mapped
      --vim.g.copilot_assume_mapped = true
      --vim.g.copilot_no_tab_map = true
    end,
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    opts = {},
    build = function()
      vim.cmd("UpdateRemotePlugins") -- You need to restart to make it works
    end,
    event = "VeryLazy",
    keys = {
      { "<leader>cce", "<cmd>CopilotChatExplain<cr>", desc = "CopilotChat - Explain code" },
      { "<leader>cct", "<cmd>CopilotChatTests<cr>",   desc = "CopilotChat - Generate tests" },
    },
  }
}

require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true,         -- use a classic bottom cmdline for search
    command_palette = true,       -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false,           -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false,       -- add a border to hover docs and signature help
  },
})


--local linters = require "lvim.lsp.null-ls.linters"
--linters.setup { { command = "flake8", filetypes = { "python" } } }
lvim.format_on_save = true;

local lspconfig = require('lspconfig')
lspconfig.pyright.setup({
  settings = {
    python = {
      analysis = {
        autoImportCompletions = true,
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        typeCheckingMode = "basic",
        useLibraryCodeForTypes = true,
        pytonPath = "/Users/omerasafkarasu/anaconda3/bin/python",
      },
    },
  },
})


-- Setup Pyright for Python
