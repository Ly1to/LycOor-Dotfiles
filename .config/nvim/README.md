# LazyVim Dotfile

Neovim 配置，基于 LazyVim

> 这是独立维护阶段的 LazyVim dotfiles。后续会合并到统一的总 dotfiles 仓库，届时以
> 总 dotfiles 为唯一配置来源。

## 目录

- `init.lua`：配置入口
- `lua/config/`：编辑器选项、快捷键和自动命令
- `lua/plugins/`：自定义插件及插件配置
- `lazyvim.json`：启用的 LazyVim 语言扩展
- `lazy-lock.json`：插件版本锁定

## 使用

将本目录放到 `~/.config/nvim`，然后启动 Neovim：

```sh
nvim
```

首次启动会自动安装插件。需要手动维护插件时，可执行：

```vim
:Lazy sync
```
