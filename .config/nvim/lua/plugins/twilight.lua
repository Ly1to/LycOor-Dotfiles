return {
  "folke/twilight.nvim",
  cmd = { "Twilight" },
  keys = {
    { "<leader>ut", "<cmd>Twilight<CR>", desc = "Toggle Twilight" },
  },
  opts = {
    context = 15, -- 光标上下多保留几行（默认 10）
  },
}
