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

-- Visual mode: arrow up/down move the selected block up/down (reindent + reselect).
-- A count is honored: `3<Down>` moves the selection 3 lines down. Out-of-range
-- counts are clamped instead of raising E16 like a bare `:m` would.
-- "v" covers charwise / linewise / blockwise visual + select
local function move_selection(dir)
  -- read the count before touching the mode below, `normal!` resets v:count
  local count = vim.v.count1

  -- leaving visual mode is what sets '< and '>, and `:m` needs those marks
  pcall(vim.cmd, "normal! \27")

  local first, last = vim.fn.line("'<"), vim.fn.line("'>")
  if first > last then
    first, last = last, first
  end

  local dest
  if dir > 0 then
    -- `:m {addr}` puts the block *after* {addr}
    dest = math.min(last + count, vim.api.nvim_buf_line_count(0))
    if dest <= last then
      vim.cmd("normal! gv")
      return
    end
  else
    dest = math.max(first - count - 1, 0)
    if dest >= first - 1 then
      vim.cmd("normal! gv")
      return
    end
  end

  vim.cmd(("'<,'>m %d"):format(dest))
  vim.cmd("normal! gv=gv")
end

map("v", "<Up>", function()
  move_selection(-1)
end, { desc = "Move selection up" })
map("v", "<Down>", function()
  move_selection(1)
end, { desc = "Move selection down" })

-- Normal mode <Right>: vertical split, exactly like LazyVim's <leader>| (<C-W>v).
-- 'splitright' is already on (LazyVim default), so the new window opens to the right.
-- Note: only kRight is remapped; `l` and other keys are untouched.
map("n", "<Right>", "<C-W>v", { desc = "Split Window Right", remap = true })

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
