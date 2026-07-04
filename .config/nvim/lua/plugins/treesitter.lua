return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "markdown",
        "markdown_inline",
        "yaml",   -- YAML front matter in .qmd files
        "python",
        "r",      -- R code cells
        "bash",
      },
    },
  },
}
