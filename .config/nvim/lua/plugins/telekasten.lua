-- Send a "Front :: Back" string to the wiki's anki_add.py helper.
-- Source note is auto-filled from the current buffer's filename.
local function anki_add(text)
  text = vim.trim(text or "")
  if text == "" then
    vim.notify("Anki: nothing selected", vim.log.levels.WARN, { title = "Anki" })
    return
  end
  local front, back = text:match("^(.-)%s*::%s*(.*)$")
  if not front then
    front, back = text, ""
  end
  front, back = vim.trim(front), vim.trim(back)
  local source = vim.fn.expand("%:t:r") -- filename without extension
  local cloze = front:match("{{c%d") ~= nil

  vim.ui.input({ prompt = "Anki tags (space-sep): " }, function(tags)
    if tags == nil then
      return
    end
    local script = vim.fn.expand("~/www/wiki/scripts/anki_add.py")
    local args = { script, "-f", front, "-s", source }
    if cloze then
      table.insert(args, "--cloze")
    end
    if back ~= "" then
      vim.list_extend(args, { "-b", back })
    end
    for _, t in ipairs(vim.split(tags, "%s+", { trimempty = true })) do
      vim.list_extend(args, { "-t", t })
    end
    vim.system(args, { text = true }, function(res)
      vim.schedule(function()
        local out = vim.trim((res.stdout or "") .. (res.stderr or ""))
        local lvl = res.code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR
        vim.notify(out ~= "" and out or ("exit " .. res.code), lvl, { title = "Anki" })
      end)
    end)
  end)
end

-- Text of the current visual selection (works while still in visual mode).
local function visual_text()
  local s = vim.fn.getpos("v")
  local e = vim.fn.getpos(".")
  local ok, lines = pcall(vim.fn.getregion, s, e, { type = vim.fn.mode() })
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
  if not ok then
    return ""
  end
  return table.concat(lines, " ")
end

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
      -- Anki: card from current line (normal) or selection (visual).
      -- Format the text as "Front :: Back"; cloze auto-detected via {{c1::...}}.
      {
        "<leader>za",
        function()
          anki_add(vim.api.nvim_get_current_line())
        end,
        desc = "Add Anki card (line)",
      },
      {
        "<leader>za",
        function()
          anki_add(visual_text())
        end,
        mode = "x",
        desc = "Add Anki card (selection)",
      },
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
