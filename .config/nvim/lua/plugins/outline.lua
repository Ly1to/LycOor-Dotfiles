-- outline.nvim：用 LSP 提供符号大纲（右侧边栏）。
return {
  "hedyhli/outline.nvim",

  keys = {
    { "<leader>o", "<cmd>Outline<CR>", desc = "Toggle Outline" },
  },
  -- opts 会在插件加载后自动执行 require("outline").setup(opts)
  opts = {
    outline_window = {
      position = "right",
      width = 25,
      focus_on_open = false,
      center_on_jump = true,
    },
    keymaps = {
      goto_location = "<CR>",
    },
  },
}
