-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local map = vim.keymap.set

pcall(vim.keymap.del, "n", "<leader>ft")
pcall(vim.keymap.del, "n", "<leader>fT")

map("n", "<leader>ft", function()
  Snacks.terminal()
end, { desc = "Terminal (cwd)" })

map("n", "<leader>fT", function()
  Snacks.terminal(nil, { cwd = LazyVim.root() })
end, { desc = "Terminal (Root Dir)" })

for _, lhs in ipairs({ "<c-/>", "<c-_>" }) do
  map("n", lhs, function()
    Snacks.terminal()
  end, { desc = "Terminal (cwd)" })
  map("t", lhs, function()
    Snacks.terminal()
  end, { desc = "Terminal (cwd)" })
end
