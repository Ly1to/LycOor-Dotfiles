-- Statusline indicator for the <F3> symbol layer (see lua/config/keymaps.lua)
-- 同时把状态栏做成透明的（配合 lua/plugins/theme.lua 的透明背景）
return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    -- 背景用 "NONE"，lualine 会自动切到透明的 statusline 高亮组
    local function mode(accent)
      local fg = Snacks.util.color("Normal") or "#c0caf5"
      -- a 段是实心色块，需要一个深色前景保证可读
      local dark = Snacks.util.color("Normal", "bg") or Snacks.util.color("Pmenu", "bg") or "#1b1d2b"
      return {
        a = { bg = accent, fg = dark, gui = "bold" },
        b = { bg = "NONE", fg = accent },
        c = { bg = "NONE", fg = fg },
      }
    end

    local accents = {
      normal = Snacks.util.color("Function") or "#7aa2f7",
      insert = Snacks.util.color("String") or "#9ece6a",
      replace = Snacks.util.color("Number") or "#ff9e64",
      visual = Snacks.util.color("Special") or "#bb9af7",
      command = Snacks.util.color("Identifier") or "#7dcfff",
    }

    opts.options.theme = {
      normal = mode(accents.normal),
      insert = mode(accents.insert),
      replace = mode(accents.replace),
      visual = mode(accents.visual),
      command = mode(accents.command),
      terminal = mode(accents.command),
      inactive = {
        a = { bg = "NONE", fg = Snacks.util.color("Comment") or "#565f89", gui = "bold" },
        b = { bg = "NONE", fg = Snacks.util.color("Comment") or "#565f89" },
        c = { bg = "NONE", fg = Snacks.util.color("Comment") or "#565f89" },
      },
    }

    table.insert(opts.sections.lualine_x, 1, {
      function()
        return "SYM"
      end,
      cond = function()
        return vim.g.symbol_layer == true
      end,
      color = function()
        return { fg = Snacks.util.color("Constant"), gui = "bold" }
      end,
      padding = { left = 1, right = 1 },
    })
  end,
}
