return {
  {
    "quarto-dev/quarto-nvim",
    ft = { "quarto" },
    dependencies = {
      "jmbuhr/otter.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      lspFeatures = {
        enabled = true,
        -- "all" handles both ```{python} and ``` python style fences
        chunks = "all",
        languages = { "python", "r", "julia", "bash" },
        diagnostics = {
          enabled = true,
          triggers = { "BufWritePost" },
        },
        completion = {
          enabled = true,
        },
      },
      codeRunner = {
        enabled = false,
      },
    },
    keys = {
      { "<leader>qp", "<cmd>QuartoPreview<cr>",  ft = "quarto", desc = "Preview" },
      { "<leader>qr", "<cmd>QuartoRender<cr>",   ft = "quarto", desc = "Render" },
      { "<leader>qa", "<cmd>QuartoActivate<cr>", ft = "quarto", desc = "Activate LSP" },
    },
  },
  {
    -- otter.nvim provides LSP features (hover, go-to-def, completion, diagnostics)
    -- inside embedded code cells by proxying requests to hidden language buffers.
    -- No extra keymaps needed — normal lsp keymaps (K, gd, gr…) just work.
    "jmbuhr/otter.nvim",
    opts = {
      buffers = {
        set_filetype = true,
        write_to_disk = false,
      },
      handle_leading_whitespace = true,
    },
  },
}
