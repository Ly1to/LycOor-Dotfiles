-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "c", "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- Sessions save directory buffers (e.g. from `nvim .` or the explorer) as
-- `badd +0 ./` / `$argadd ./`. Restoring them creates a phantom "empty" buffer
-- named after the directory, which only turns out to be the explorer when opened.
-- Drop those buffers (and the matching args) right after a session is restored.
vim.api.nvim_create_autocmd("SessionLoadPost", {
  group = vim.api.nvim_create_augroup("user_session_cleanup", {}),
  callback = function()
    vim.schedule(function()
      -- wipe unloaded directory buffers
      for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        local name = vim.api.nvim_buf_get_name(buf)
        if
          vim.api.nvim_buf_is_valid(buf)
          and name ~= ""
          and not vim.api.nvim_buf_is_loaded(buf)
          and vim.bo[buf].buftype == ""
          and vim.fn.isdirectory(name) == 1
        then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end

      -- drop directory entries from the arglist so they are not saved again
      local keep, changed = {}, false
      for _, arg in ipairs(vim.fn.argv()) do
        if vim.fn.isdirectory(vim.fn.fnamemodify(arg, ":p")) == 1 then
          changed = true
        else
          keep[#keep + 1] = vim.fn.fnameescape(arg)
        end
      end
      if changed then
        vim.cmd("silent! %argdel")
        if #keep > 0 then
          vim.cmd("silent! $argadd " .. table.concat(keep, " "))
        end
      end
    end)
  end,
})
