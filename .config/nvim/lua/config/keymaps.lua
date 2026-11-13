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

-- Insert mode, ctrl+o to new a line above current line
vim.keymap.set("i", "<C-o>", "<Esc>O", { desc = "Insert line above" })

-- leader+v maps to ctrl+v
vim.keymap.set("n", "<leader>v", "<C-v>", { desc = "Visual Block Mode" })

-- Normal mode, ctrl+n enters insert mode then presses Enter
map("n", "<C-n>", "i<CR>", { desc = "Insert mode + new line" })

-- Insert mode symbol layer: <F3> toggles a "shift layer" where the unshifted
-- keys insert their shifted counterpart (US layout).
-- Press <F3> again (or leave insert mode) to go back to normal typing.
local symbols = {
  -- digits
  ["1"] = "!",
  ["2"] = "@",
  ["3"] = "#",
  ["4"] = "$",
  ["5"] = "%",
  ["6"] = "^",
  ["7"] = "&",
  ["8"] = "*",
  ["9"] = "(",
  ["0"] = ")",
  -- symbols
  ["-"] = "_",
  ["="] = "+",
  ["["] = "{",
  ["]"] = "}",
  ["\\"] = "|",
  [";"] = ":",
  ["'"] = '"',
  [","] = "<",
  ["."] = ">",
  ["/"] = "?",
  ["`"] = "~",
}

local symbol_layer_on = false

-- The layer is applied as *buffer-local* insert mappings, so global/buffer
-- mappings from mini.pairs, Neovim defaults (`;` `,` `.`) etc. just get shadowed
-- and automatically come back when we delete ours again.
local function set_symbol_layer(on)
  vim.g.symbol_layer = on
  local buf = vim.api.nvim_get_current_buf()
  for lhs, sym in pairs(symbols) do
    if on then
      vim.keymap.set("i", lhs, sym, { buffer = buf, desc = "Symbol layer: " .. lhs .. " -> " .. sym })
    else
      pcall(vim.keymap.del, "i", lhs, { buffer = buf })
    end
  end
  vim.cmd.redrawstatus()
end

map("i", "<F3>", function()
  symbol_layer_on = not symbol_layer_on
  set_symbol_layer(symbol_layer_on)
end, { desc = "Toggle symbol layer (digits -> symbols)" })

-- turn the symbol layer off automatically when leaving insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  callback = function()
    if symbol_layer_on then
      symbol_layer_on = false
      set_symbol_layer(false)
    end
  end,
})
