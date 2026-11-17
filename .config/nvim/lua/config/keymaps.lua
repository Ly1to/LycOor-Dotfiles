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

-- Terminal mode: a single <F1> puts the terminal buffer into normal mode instead
-- of snacks' default double <Escape> (200ms window). <C-\><C-n> is the builtin
-- "leave terminal insert mode" sequence, so the shell never sees the keypress.
-- Mappings in "t" mode are only active inside terminal buffers, so <F1> keeps
-- its normal/help meaning everywhere else.
map("t", "<F1>", "<C-\\><C-n>", { desc = "Terminal Normal Mode" })

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

-- The window's alternate buffer (`#`) is the file we were on before this one,
-- which is exactly what a fresh split should show, and it survives the split.
-- (getbufinfo().lastused only has 1s resolution, so it cannot be used as MRU:
-- buffers opened within the same second tie.)
local function other_buf(cur)
  local alt = vim.fn.bufnr("#")
  if alt > 0 and alt ~= cur and vim.bo[alt].buflisted then
    return alt
  end
  -- no usable alternate: take any other listed buffer, else nil (nothing to show)
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if b ~= cur and vim.bo[b].buflisted then
      return b
    end
  end
end

-- Normal mode <Right>: vertical split, like LazyVim's <leader>| (<C-W>v), but the
-- new window shows *another* file instead of the one already in the current
-- window. With only one buffer there is nothing else to show, so it stays put.
-- 'splitright' is already on (LazyVim default), so the new window opens to the right.
-- Note: only kRight is remapped; `l` and other keys are untouched.
map("n", "<Right>", function()
  -- read `#` before splitting: it is per window, and the new window is the one
  -- we switch buffers in
  local other = other_buf(vim.api.nvim_get_current_buf())
  vim.cmd("vsplit")
  if other then
    vim.api.nvim_win_set_buf(0, other)
  end
end, { desc = "Split Window Right (other buffer)" })

-- Normal mode <Left>: close the current window, silently a no-op on the last
-- window of the tab (no E444 noise, and it can never quit Neovim; the buffer
-- stays loaded/hidden, so `:b` can bring it back).
map("n", "<Left>", function()
  if #vim.api.nvim_tabpage_list_wins(0) > 1 then
    vim.cmd("close")
  end
end, { desc = "Close Window" })

-- leader+v maps to ctrl+v
vim.keymap.set("n", "<leader>v", "<C-v>", { desc = "Visual Block Mode" })

-- Normal mode, ctrl+n enters insert mode then presses Enter
map("n", "<C-n>", "i<CR>", { desc = "Insert mode + new line" })

-- Insert mode, ctrl+n is Enter: saves reaching for the far away <CR> key.
-- While the blink.cmp menu is open the key keeps its completion meaning
-- (select next item) so completion navigation is not lost.
-- NOTE: a Lua callback mapping ignores a *returned* string, so the newline has
-- to be queued with nvim_feedkeys ("ni" = put it in front, no remap).
map("i", "<C-n>", function()
  local ok, cmp = pcall(require, "blink.cmp")
  if ok and cmp.is_menu_visible() then
    cmp.select_next()
    return
  end
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), "ni", false)
end, { desc = "New line (Enter)" })

-- Insert mode, ctrl+- types ">" (a shifted "." that needs an awkward reach).
-- <C-_> (ctrl+shift+-) is registered as well: a legacy terminal cannot report
-- ctrl+- at all and sends 0x1F instead, which nvim reads as <C-_>. Insert mode
-- only, so the n/t terminal toggles on <C-_>/<C-/> keep their meaning.
-- NOTE: a plain string rhs inserts its text as typed keys, so no callback is
-- needed here.
for _, lhs in ipairs({ "<C-->", "<C-_>" }) do
  map("i", lhs, ">", { desc = "Insert >" })
end

-- Insert mode, ctrl+0 types "{". Unlike ">" above this one has to go through
-- mini.pairs to auto-close exactly like a typed "{": `remap = true`
-- (non-noremap) re-resolves the rhs through the insert mappings, and that is
-- where mini.pairs' expr map on "{" lives. A plain noremap rhs would bypass it
-- and insert a bare "{" instead of the "{}" pair.
map("i", "<C-0>", "{", { remap = true, desc = "Insert { (auto-paired)" })

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
