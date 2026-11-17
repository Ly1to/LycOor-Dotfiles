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
        -- 注意：position 必须放在 win 下面（顶层 position 会被 snacks 忽略，
        -- 结果 Snacks.terminal() 不带命令时开成底部 split，t 模式的 <C-l>
        -- 会被 LazyVim 的 term_nav 抢走做 <C-w>l，shell 收不到 ^L 无法清屏）。
        win = {
          position = "float",
          border = "rounded",
          width = 0.85,
          height = 0.85,
          wo = {
            -- 描边颜色走自定义组，其它沿用 snacks 默认（背景透明等）
            winhighlight = table.concat({
              "Normal:SnacksNormal",
              "NormalNC:SnacksNormalNC",
              "WinBar:SnacksWinBar",
              "WinBarNC:SnacksWinBarNC",
              "FloatBorder:SnacksTerminalBorder",
            }, ","),
            -- 内边距：空 winbar 留出一行上边距，statuscolumn 留出一格左边距
            -- （nvim 没有真正的 padding 选项，右侧/下侧无法留白）
            winbar = " ",
            statuscolumn = " ",
            signcolumn = "no",
            foldcolumn = "0",
          },
        },
      },
    },
    init = function()
      -- 边框颜色：默认用主题的强调色（Function）。想换成普通描边就改成 FloatBorder，
      -- 想更醒目可以写具体的 fg，例如 { fg = "#7aa2f7" }
      local function set()
        vim.api.nvim_set_hl(0, "SnacksTerminalBorder", { link = "Function" })
      end
      set()
      vim.api.nvim_create_autocmd("ColorScheme", {
        group = vim.api.nvim_create_augroup("snacks_terminal_border", { clear = true }),
        callback = set,
      })
    end,
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

  {
    "folke/snacks.nvim",
    opts = {
      image = {
        -- open image file to auto render
        enabled = true,
      },
    },
  },
}
