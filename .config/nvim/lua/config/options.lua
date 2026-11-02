-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
vim.opt.wrap = true

vim.opt.scrolloff = 8

-- 行号列宽度设为 4，避免行号超过 3 位数时整列左右跳动
vim.opt.numberwidth = 4

-- 补全菜单最多显示 15 行
vim.opt.pumheight = 15

-- 按键等待多少毫秒后弹出 which-key 菜单（默认 300，调小更跟手）
vim.opt.timeoutlen = 200

-- 按键序列的超时时间，越小 Esc 越快生效（默认 50）
vim.opt.ttimeoutlen = 10
