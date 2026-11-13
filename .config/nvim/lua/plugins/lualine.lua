-- Statusline indicator for the <F3> symbol layer (see lua/config/keymaps.lua)
return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
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
