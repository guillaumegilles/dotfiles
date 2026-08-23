return {
  "folke/snacks.nvim",
  opts = {
    explorer = {
      -- Make the explorer use the picker settings below
      enabled = true,
    },
    picker = {
      sources = {
        explorer = {
          -- Show dotfiles (hidden files) by default
          hidden = true,
          -- Also show files ignored by .gitignore (optional).
          -- Set to false if you only want dotfiles, not git-ignored files.
          ignored = true,
        },
      },
    },
  },
}
