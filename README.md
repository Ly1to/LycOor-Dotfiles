# LycOor Dotfiles

> Talk is easy, show me your code.

我的个人 Linux 配置集合，覆盖 shell、编辑器、终端、配色和信息展示。配置主要以 Arch
Linux 上的日常使用为背景，但大部分内容并不依赖具体发行版。

仓库采用“裸 Git 目录 + `$HOME` 工作区”的管理方式：

- Git 元数据位于 `~/.dotfiles`
- 实际配置直接放在 `~/.zshrc`、`~/.config/...` 等原始位置
- 不使用软链接，也不额外维护一套 `dotfiles/` 工作目录

## 配置一览

| 模块 | 入口 | 说明 |
| --- | --- | --- |
| Zsh | `.zshrc` | Zinit 插件管理、补全、历史记录、Vi 模式、别名和快捷函数 |
| Git | `.gitconfig` | Git 用户信息与常用短别名 |
| Starship | `.config/starship.toml` | 精简提示符配置 |
| Neovim | `.config/nvim/` | 基于 LazyVim 的编辑器配置 |
| Kitty | `.config/kitty/` | 终端、字体、窗口、快捷键和配色 |
| Wallust | `.config/wallust/` | 根据壁纸生成 Kitty 配色 |
| Fastfetch | `.config/fastfetch/` | Arch 风格的启动信息面板 |

## 功能

### Zsh

- Zinit 首次启动时自动克隆，插件包括补全、自动建议、语法高亮、Vi
  模式和历史子串搜索
- 补全不区分大小写，并复用当前 `LS_COLORS`
- 共享、去重的持久化命令历史
- 使用 Starship、`fzf`、`zoxide` 和 `yazi` 增强交互体验
- 提供 eza 文件列表、Fastfetch 和 dotfiles Git 包装等常用别名

常用别名与函数：

| 命令 | 作用 |
| --- | --- |
| `cf` | 对 `~/.dotfiles` 与 `$HOME` 执行 Git 操作 |
| `ls` / `ll` / `lt` / `lta` | 使用 eza 查看普通、详细、两级目录或三级全部文件 |
| `ff` | 使用 `arch-extended` 配置运行 Fastfetch |
| `yz` | 打开 Yazi，并在退出后切换到 Yazi 中的目录 |
| `mkcd <dir>` | 创建目录并立即进入 |
| `..` / `...` | 快速返回上一级或上两级目录 |

Shell 还启用了 `Ctrl+E` 调用 `edit-command-line`，可在 `$EDITOR` 中编辑当前命令。

### Neovim

Neovim 配置基于 LazyVim，首次启动时会自动安装 `lazy.nvim` 和插件。启用的语言扩展包括：

- C/C++
- CMake
- Git
- Java
- JSON
- Markdown
- Python
- TOML

额外配置了 Blink 补全、右侧符号大纲、Snacks 浮窗终端和 Twilight 聚焦模式。

部分自定义快捷键：

| 快捷键 | 作用 |
| --- | --- |
| `<leader>o` | 打开或关闭符号大纲 |
| `<leader>ut` | 打开或关闭 Twilight |
| `<leader>ft` | 在项目目录打开终端 |
| `<leader>fT` | 在项目根目录打开终端 |
| `Ctrl+/` 或 `Ctrl+_` | 打开或切换浮窗终端 |

### Kitty

Kitty 配置按职责拆分为多个文件：`kitty.conf` 只负责汇总，字体、光标、界面、快捷键
和配色分别放在 `font.conf`、`cursor.conf`、`ui.conf`、`keymaps.conf` 和
`colors.conf` 中。窗口默认启用透明背景、极简装饰和 powerline 标签栏。

自定义快捷键：

| 快捷键 | 作用 |
| --- | --- |
| `Ctrl+Shift+T` | 在当前目录新建标签页 |
| `Ctrl+Shift+N` | 关闭当前标签页 |
| `Ctrl+Shift+L` / `Ctrl+Shift+H` | 切换到下一个 / 上一个标签页 |
| `Ctrl+Shift+I` | 查看滚动历史 |

### 动态配色与信息面板

Wallust 会根据指定的壁纸生成 `.config/kitty/colors.conf`，并由 Kitty 的
`kitty.conf` 引入。Fastfetch 的 `arch-extended` 配置则提供分区清晰、信息更完整的系统
面板，可通过 `ff` 运行。

## 依赖

必须安装：

- `git`
- `zsh`
- `kitty`
- Neovim 0.11 或更新的版本

以下工具为可选依赖；缺少时 shell 仍可启动，但对应功能不可用：

- `starship`：提示符
- `eza`：文件列表别名
- `fzf`：模糊查找和 shell 集成
- `zoxide`：目录跳转
- `yazi`：文件管理器
- `fastfetch`：系统信息面板
- `wallust`：Kitty 动态配色

终端字体需要 `Noto Sans Mono`，中文回退字体使用 `LXGW WenKai`。如果希望 eza 图标完整
显示，可以另外安装任一 Nerd Font。

## 安装

先将已有配置备份到安全位置，再使用裸仓库方式克隆：

```sh
git clone --bare git@github.com:Ly1to/LycOor-Dotfiles.git "$HOME/.dotfiles"
```

没有配置 GitHub SSH 时也可以使用 HTTPS：

```sh
git clone --bare https://github.com/Ly1to/LycOor-Dotfiles.git "$HOME/.dotfiles"
```

定义临时 Git 包装并检出配置：

```sh
dotgit() {
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

dotgit config status.showUntrackedFiles no
dotgit checkout
```

`dotgit checkout` 如果报告目标文件已存在，请先逐个比较并备份冲突文件，不要直接使用
强制覆盖。检出完成后重新打开 shell，Zinit 会在首次启动时安装自身及插件：

```sh
exec zsh
```

首次运行 Neovim 时等待插件安装完成。若 Kitty 提示找不到 `colors.conf`，先生成一次主题：

```sh
wallust run /path/to/wallpaper
```

然后分别通过 `nvim`、`kitty` 和 `ff` 验证编辑器、终端与信息面板。

## 日常使用

检出 `.zshrc` 后会自动获得 `cf` 别名：

```sh
cf status
cf add .zshrc .config/nvim/
cf commit -m "update shell config"
cf push
```

拉取远端更新：

```sh
cf pull --rebase
```

仓库关闭了未跟踪文件的显示。新增配置必须显式 `add`，这也意味着 `cf status` 不能代替
对敏感文件的检查。

## 注意事项

- 不要执行 `cf add .`。工作区是整个 `$HOME`，该命令可能把缓存、密钥、下载内容和其他
  无关文件加入仓库。
- 不要跟踪 SSH 私钥、云服务凭据、访问令牌、`.npmrc`、浏览器数据或其他敏感内容。提交
  前使用 `cf diff --cached` 检查暂存区。
- `.config/fastfetch/arch-extended.jsonc` 中 `arch.txt` 使用了绝对路径
  `/home/lycor/.config/fastfetch/arch.txt`。如果用户名或家目录不同，需要改为实际路径。
- `.config/kitty/colors.conf` 由 Wallust 生成，不要直接手工维护；如需调整输出，应修改
  `.config/wallust/templates/kitty.conf`。Neovim 的 `lazy-lock.json` 则会提交到仓库，
  用于固定插件版本。

## 目录结构

```text
$HOME
├── .gitconfig
├── .zshrc
├── README.md
└── .config
    ├── fastfetch
    │   ├── arch-extended.jsonc
    │   ├── arch.txt
    │   └── config.jsonc
    ├── kitty
    │   ├── cursor.conf
    │   ├── font.conf
    │   ├── keymaps.conf
    │   ├── kitty.conf
    │   └── ui.conf
    ├── nvim
    │   ├── lua
    │   ├── init.lua
    │   ├── lazy-lock.json
    │   └── lazyvim.json
    ├── starship.toml
    └── wallust
        ├── templates
        └── wallust.toml
```
