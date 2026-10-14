local servers = {
  "lua_ls",
  "basedpyright",
  "ruff",
  "vtsls",
  "eslint",
  "jsonls",
  "yamlls",
  "taplo",
  "bashls",
  "dockerls",
}

-- Formatters used by conform (see formatting.lua)
local formatters = { "stylua", "prettierd", "shfmt", "sqlfluff" }

return {
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = { { path = "${3rd}/luv/library", words = { "vim%.uv" } } },
    },
  },
  {
    -- Not lazy: puts Mason's bin dir on PATH for LSP servers and formatters
    "mason-org/mason.nvim",
    lazy = false,
    opts = {},
  },
  {
    -- Installs servers (lspconfig names) and formatters on startup.
    -- Not lazy: it hooks VimEnter, which has already fired by VeryLazy.
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    lazy = false,
    dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
    opts = { ensure_installed = vim.list_extend(vim.deepcopy(servers), formatters) },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "saghen/blink.cmp",
      "b0o/SchemaStore.nvim",
    },
    config = function()
      vim.diagnostic.config({
        severity_sort = true,
        virtual_text = { spacing = 2, source = "if_many" },
        float = { border = "rounded", source = "if_many" },
      })

      -- One position encoding for all servers (basedpyright and ruff differ by default)
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities({
          general = { positionEncodings = { "utf-16" } },
        }),
      })

      vim.lsp.config("basedpyright", {
        settings = {
          basedpyright = { analysis = { typeCheckingMode = "standard" } },
        },
      })
      vim.lsp.config("jsonls", {
        settings = {
          json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
        },
      })
      vim.lsp.config("yamlls", {
        settings = {
          yaml = {
            schemaStore = { enable = false, url = "" },
            schemas = require("schemastore").yaml.schemas(),
          },
        },
      })

      -- Enables every Mason-installed server (automatic_enable)
      require("mason-lspconfig").setup({
        -- stylua is installed as a formatter for conform, not as a server
        automatic_enable = { exclude = { "stylua" } },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp", { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          -- basedpyright owns hover for Python
          if client and client.name == "ruff" then
            client.server_capabilities.hoverProvider = false
          end

          -- Neovim defaults also apply: K, grn, gra, grr, gri, grt, gO
          local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = args.buf, desc = desc })
          end
          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")
          map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
        end,
      })
    end,
  },
}
