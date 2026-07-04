return {
  {
    "nvim-telekasten/telekasten.nvim",
    dependencies = {
      -- Telekasten uses telescope for its pickers. LazyVim's default picker is
      -- snacks, so we pull telescope in only as a dependency here.
      "nvim-telescope/telescope.nvim",
      "nvim-lua/plenary.nvim",
    },
    cmd = "Telekasten",
    keys = {
      { "<leader>z", "", desc = "+zettelkasten" },
      { "<leader>zz", "<cmd>Telekasten panel<cr>", desc = "Telekasten panel" },
      { "<leader>zf", "<cmd>Telekasten find_notes<cr>", desc = "Find notes" },
      { "<leader>zg", "<cmd>Telekasten search_notes<cr>", desc = "Search (grep) notes" },
      { "<leader>zd", "<cmd>Telekasten find_daily_notes<cr>", desc = "Find daily notes" },
      { "<leader>zn", "<cmd>Telekasten new_note<cr>", desc = "New note" },
      { "<leader>zt", "<cmd>Telekasten show_tags<cr>", desc = "Show tags" },
      { "<leader>zb", "<cmd>Telekasten show_backlinks<cr>", desc = "Show backlinks" },
      { "<leader>zi", "<cmd>Telekasten insert_link<cr>", desc = "Insert link" },
      -- follow the [[link]] / jump on the calendar / toggle todo under cursor
      { "<leader>z]", "<cmd>Telekasten follow_link<cr>", desc = "Follow link" },
    },
    opts = {
      home = vim.fn.expand("~/www/wiki"),
      -- keep GitHub-Wiki compatibility
      extension = ".md",
      -- flat vault: don't nest each note in its own dir
      subdirs_in_links = false,
      -- human-readable filenames instead of timestamps
      new_note_filename = "title",
      -- link style: [[wikilinks]] like GitHub Wiki (not markdown [text](url))
      journal_auto_open = false,
      dailies = vim.fn.expand("~/www/wiki/journal"),
      templates = vim.fn.expand("~/www/wiki/templates"),
    },
  },
}
