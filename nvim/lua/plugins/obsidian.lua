return {
  "epwalsh/obsidian.nvim",
  version = "*", -- recommended, use latest release instead of latest commit
  -- lazy = true,
  -- ft = "markdown",
  -- Replace the above line with this if you only want to load obsidian.nvim for markdown files in your vault:
  event = {
    -- If you want to use the home shortcut '~' here you need to call 'vim.fn.expand'.
    -- E.g. "BufReadPre " .. vim.fn.expand "~" .. "/my-vault/**.md"
    "BufReadPre /home/rene/Documents/personal/ObsidianVault/**",
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function(_, opts)
    local obsidian = require("obsidian")
    obsidian.setup(opts)

    vim.keymap.set({ "n", "v" }, "<leader>ol", ":ObsidianLink<CR>", { buffer = true, desc = "[O]bsidian [L]ink" })

    vim.api.nvim_create_user_command("WeeklyEntry", function()
      local date = os.date("%G-w%V", os.time())
      local client = obsidian.get_client()

      --create new note and add metadata
      local note = client:create_note({ title = tostring(date), dir = "weekly", template = "weekly.md" })
      client:open_note(note)
    end, {})
  end,
  opts = {
    workspaces = {
      {
        name = "work",
        path = "~/Documents/personal/ObsidianVault",
      },
    },

    daily_notes = {
      folder = "daily",
      -- Optional, if you want to change the date format for the ID of daily notes.
      date_format = "%Y-%m-%d",
      -- Optional, if you want to change the date format of the default alias of daily notes.
      alias_format = "%B %-d, %Y",
      -- Optional, if you want to automatically insert a template from your template directory like 'daily.md'
      template = "daily.md",
    },

    -- disable_frontmatter = true,

    new_notes_location = "notes_subdir",
    notes_subdir = "vault",

    templates = {
      subdir = "templates",
      date_format = "%Y-%m-%d",
      time_format = "%H:%M",
      -- A map for custom variables, the key should be the variable and the value a function
      substitutions = {
        isoweek = function()
          return os.date("%G-w%V", os.time())
        end,
        isoprevweek = function()
          local adjustment = -7 * 24 * 60 * 60 -- One week in seconds
          return os.date("%G-w%V", os.time() + adjustment)
        end,
        isonextweek = function()
          local adjustment = 7 * 24 * 60 * 60 -- One week in seconds
          return os.date("%G-w%V", os.time() + adjustment)
        end,
      },
    },

    follow_url_func = function(url)
      -- Open the URL in the default web browser.
      vim.fn.jobstart({ "xdg-open", url })
    end,

    preferred_link_style = "markdown",
    ---@param title string|?
    ---@return string
    note_id_func = function(title)
      -- Create note IDs in a Zettelkasten format with a timestamp and a suffix.
      -- In this case a note with the title 'My new note' will be given an ID that looks
      -- like '1657296016-my-new-note', and therefore the file name '1657296016-my-new-note.md'
      local suffix = ""
      if title ~= nil then
        -- If title is given, transform it into valid file name.
        suffix = title:gsub(" ", "-"):gsub("[^A-Za-z0-9-]", ""):lower()
      else
        suffix = suffix .. tostring(os.date("%Y_%m_%d", os.time())) .. "-"
        -- If title is nil, just add 4 random uppercase letters to the suffix.
        for _ = 1, 4 do
          suffix = suffix .. string.char(math.random(65, 90))
        end
      end
      return suffix
    end,

    ---@param spec { id: string, dir: obsidian.Path, title: string|? }
    note_path_func = function(spec)
      -- This is equivalent to the default behavior.
      local path = spec.dir / tostring(spec.id)
      return path:with_suffix(".md")
    end,

    note_frontmatter_func = function(note)
      -- Add the title of the note as an alias.
      if note.title then
        note:add_alias(note.title)
      end

      local out = { id = note.id, aliases = note.aliases, tags = note.tags }

      -- `note.metadata` contains any manually added fields in the frontmatter.
      -- So here we just make sure those fields are kept in the frontmatter.
      if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
        for k, v in pairs(note.metadata) do
          out[k] = v
        end
      end

      return out
    end,

    mappings = {
      ["gd"] = {
        action = function()
          return require("obsidian").util.gf_passthrough()
        end,
        opts = { noremap = false, expr = true, buffer = true },
      },
      ["<leader>ch"] = {
        action = function()
          return require("obsidian").util.toggle_checkbox()
        end,
        opts = { buffer = true },
      },
      ["<leader>st"] = {
        action = function()
          return "<cmd>ObsidianTags<CR>"
        end,
        opts = { buffer = true, expr = true, desc = "Search Obsidian [T]ags" },
      },
      ["<leader>on"] = {
        action = function()
          return "<cmd>ObsidianNew<CR>"
        end,
        opts = { buffer = true, expr = true, desc = "[N]ew Obsidian note" },
      },
      ["<leader>ot"] = {
        action = function()
          return "<cmd>ObsidianTemplate<CR>"
        end,
        opts = { buffer = true, expr = true, desc = "Open [O]bsidian [T]emplate" },
      },
      ["<leader>or"] = {
        action = function()
          return "<cmd>ObsidianBacklinks<CR>"
        end,
        opts = { buffer = true, expr = true, desc = "[O]bsidian Backlinks" },
      },
      ["<leader>oal"] = {
        action = function()
          return "<cmd>ObsidianLinks<CR>"
        end,
        opts = { buffer = true, expr = true, desc = "[O]bsidian [L]inks" },
      },
    },
  },
}
