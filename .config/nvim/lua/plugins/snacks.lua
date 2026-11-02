return {
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = {
            hidden = true,
            ignored = false,
          },
        },
      },
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        -- focus on the list, normal mode
        focus = "list",
      },
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          cmdline = {
            -- literaly define cmd_history on input
            focus = "input",
          },
        },
      },
    },
  },

  {
    "folke/snacks.nvim",
    opts = {
      terminal = {
        position = "float",
      },
    },
    keys = {
      -- remap
      {
        "<c-/>",
        function()
          Snacks.terminal()
        end,
        desc = "Terminal (Float)",
        mode = { "n", "t" },
      },
      {
        "<c-_>",
        function()
          Snacks.terminal()
        end,
        desc = "Terminal (Float)",
        mode = { "n", "t" },
      },
    },
  },
}
