# LycOor Dotfiles

> Talk is easy, show me your code.

我的个人 Linux 配置集合，覆盖 shell、编辑器、终端、配色和信息展示。配置主要以 Arch
Linux 上的日常使用为背景，但大部分内容并不依赖具体发行版。

仓库采用“裸 Git 目录 + `$HOME` 工作区”的管理方式：

- Git 元数据位于 `~/.dotfiles`
- 实际配置直接放在 `~/.zshrc`、`~/.config/...` 等原始位置
- 不使用软链接，也不额外维护一套 `dotfiles/` 工作目录
- **只有一个 `main` 分支**，多台机器共用同一条历史线

## 仓库模型

### 单一分支

早期用“每台机器一条分支 + 互相 cherry-pick”的方式同步，结果两条分支长期各有 23 个
提交、其中 15 对是完全重复的补丁，合并时冲突不断。现在改为：

- 只有 `main` 一条业务分支，所有机器都在它上面工作
- 同步只做 `cf pull --rebase` / `cf push`，**不再 cherry-pick**（cherry-pick 会为同一
  改动生成新提交，重复历史就是这么来的）

### 机器差异放在未跟踪的本地层

同一份配置要在不同机器上跑，差异不应该进历史。约定如下：

| 差异项 | 落点 | 生效机制 |
| --- | --- | --- |
| 用户名 / 邮箱 | `~/.gitconfig.local` | `.gitconfig` 里 `[include]` 引入；文件缺失时 git 静默跳过 |
| 终端字体 / 字号 | `~/.config/kitty/*.local.conf` | `kitty.conf` 末尾 `globinclude *.local.conf`，后加载即覆盖 |
| 包管理器目录 | `.zshrc` 内 `[[ -d ... ]]` 判断 | 目录不存在就不加入 `PATH`，两台机器可共用一份配置 |
| Wallust 生成的配色 | `.config/kitty/colors.conf` | 生成物，不跟踪 |

这些本地文件的忽略规则写在仓库自带的 `.gitignore`（即 `~/.gitignore`）里，所以
`*.local.conf`、`.gitconfig.local` 不会被误提交。

## 配置一览

| 模块 | 入口 | 说明 |
| --- | --- | --- |
| Zsh | `.zshrc` | Zinit 插件管理、补全、历史记录、Vi 模式、别名和快捷函数 |
| Git | `.gitconfig` | 常用短别名；用户信息由 `~/.gitconfig.local` 提供 |
| Starship | `.config/starship.toml` | 精简提示符配置 |
| Neovim | `.config/nvim/` | 基于 LazyVim 的编辑器配置 |
| Kitty | `.config/kitty/` | 终端、字体、窗口、快捷键和配色 |
| Wallust | `.config/wallust/` | 根据壁纸生成 Kitty 配色 |
| Fastfetch | `.config/fastfetch/` | Arch 风格的启动信息面板 |
| 忽略规则 | `.gitignore` | 排除本地覆盖文件与生成物 |

## 功能

### Zsh

- Zinit 首次启动时自动克隆，插件包括补全、自动建议、语法高亮、Vi
  模式和历史子串搜索
- 补全不区分大小写，并复用当前 `LS_COLORS`
- 共享、去重的持久化命令历史
- 使用 Starship、`fzf`、`zoxide` 和 `yazi` 增强交互体验
- `EDITOR` 指向 `nvim`，`vi` 也被路由到 `nvim`
- `PATH` 由 `typeset -U path` 去重；pnpm、npm 全局目录和 `~/.local/bin` 只在目录存在
  时才加入，因此同一份 `.zshrc` 可以跨机器使用

常用别名与函数：

| 命令 | 作用 |
| --- | --- |
| `cf` | 对 `~/.dotfiles` 与 `$HOME` 执行 Git 操作 |
| `ls` / `ll` / `lt` / `lta` | 使用 eza 查看普通、详细、两级目录或三级全部文件 |
| `ff` | 使用 `arch-extended` 配置运行 Fastfetch |
| `yz` | 打开 Yazi，并在退出后切换到 Yazi 中的目录 |
| `dl` | 用 Dolphin 打开当前目录 |
| `vi` | 无参数时用 `nvim .` 打开当前目录，否则透传参数 |
| `mkcd <dir>` | 创建目录并立即进入 |
| `pf` / `rb` | 关机 / 重启 |
| `..` / `...` | 快速返回上一级或上两级目录 |

Shell 还启用了 `Ctrl+E` 调用 `edit-command-line`，可在 `$EDITOR` 中编辑当前命令。

### Neovim

Neovim 配置基于 LazyVim，首次启动时会自动安装 `lazy.nvim` 和插件。启用的语言扩展包括：

- C/C++（clangd）
- CMake
- Git
- Java
- JSON
- Markdown
- Python
- TOML
- TypeScript（vtsls）
- YAML

额外配置了 Blink 补全、Flash 跳转、右侧符号大纲、Snacks 浮窗终端与图片渲染、Lualine
状态栏和 Twilight 聚焦模式。

部分自定义快捷键：

| 快捷键 | 作用 |
| --- | --- |
| `<Right>` | 垂直分屏，新窗口显示上一个缓冲区（只有一个缓冲区时不动作） |
| `<Left>` | 关闭当前窗口；最后一个窗口时静默忽略 |
| `<Up>` / `<Down>`（可视模式） | 上下移动选中的行，并保持选中 |
| `Ctrl+O`（插入模式） | 在上方新开一行 |
| `Ctrl+N` | 普通模式进入插入模式并换行；插入模式下等同 `<CR>`（补全菜单打开时保留“选择下一项”） |
| `Ctrl+-` / `Ctrl+_`（插入模式） | 输入 `>` |
| `Ctrl+0`（插入模式） | 输入 `{`，经 mini.pairs 自动补成 `{}` |
| `F3`（插入模式） | 切换符号层：数字/符号键输入对应的 Shift 字符，退出插入模式自动关闭 |
| `<leader>v` | 块可视模式 |
| `<leader>o` | 打开或关闭符号大纲 |
| `<leader>ut` | 打开或关闭 Twilight |
| `<leader>ft` / `<leader>fT` | 在项目目录 / 项目根目录打开终端 |
| `Ctrl+/` 或 `Ctrl+_` | 打开或切换浮窗终端 |

### Kitty

Kitty 配置按职责拆分为多个文件：`kitty.conf` 只负责汇总，字体、光标、界面、快捷键
和配色分别放在 `font.conf`、`cursor.conf`、`ui.conf`、`keymaps.conf` 和
`colors.conf` 中。窗口默认启用透明背景、极简装饰和 powerline 标签栏。

`kitty.conf` 末尾的 `globinclude *.local.conf` 用于加载本机字体覆盖：默认字体为
`CodeNewRoman Nerd Font`，斜体用 `VictorMono Nerd Font`，中文通过
`symbol_map U+4E00-U+9FFF` 回退到 `LXGW WenKai`。要换字体只在本机放一个
`font.local.conf`，无需改动被跟踪的文件。

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
面板，可通过 `ff` 运行；其中的 logo 使用 `~` 相对路径，跨机器无需修改。

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
- `dolphin`：`dl` 函数使用的文件管理器

终端字体默认使用 `CodeNewRoman Nerd Font` 与 `VictorMono Nerd Font`，中文回退字体为
`LXGW WenKai`。字体缺失时 Kitty 会自动回退到其他已安装字体，不会报错；也可以在本机
`font.local.conf` 里改成自己装的字体。

## 安装

先将已有配置备份到安全位置，再使用裸仓库方式克隆：

```sh
git clone --bare git@github.com:Ly1to/LycOor-Dotfiles.git "$HOME/.dotfiles"
```

没有配置 GitHub SSH 时也可以使用 HTTPS：

```sh
git clone --bare https://github.com/Ly1to/LycOor-Dotfiles.git "$HOME/.dotfiles"
```

定义临时 Git 包装并检出配置（克隆得到的是裸仓库，`status.showUntrackedFiles` 这类设置
不会随仓库传来，需要手动设置一次）：

```sh
dotgit() {
  git --git-dir="$HOME/.dotfiles" --work-tree="$HOME" "$@"
}

dotgit config status.showUntrackedFiles no
dotgit checkout
```

`dotgit checkout` 如果报告目标文件已存在，请先逐个比较并备份冲突文件，不要直接使用
强制覆盖。

检出后 **必须** 创建本机身份文件，否则提交会缺少作者信息：

```sh
cat > "$HOME/.gitconfig.local" <<'EOF'
[user]
    name = your-name
    email = you@example.com
EOF
```

裸克隆不会生成 `refs/remotes/origin/*`，因此要让 `cf status` / `cf pull` 具备上游信息，
需要补一次远程跟踪 refspec：

```sh
dotgit config remote.origin.fetch '+refs/heads/*:refs/remotes/origin/*'
dotgit fetch origin
dotgit branch --set-upstream-to=origin/main main
```

重新打开 shell，Zinit 会在首次启动时安装自身及插件：

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

在另一台机器上同步：

```sh
cf pull --rebase
```

只在 `main` 上工作，机器相关的差异写到本地覆盖层（见上文表格），不要为不同机器开分支。
本地改动与远端分叉时用 `cf pull --rebase` 收敛，**不要** 用 cherry-pick 搬运提交。

仓库关闭了未跟踪文件的显示。新增配置必须显式 `add`，这也意味着 `cf status` 不能代替
对敏感文件的检查。

## 注意事项

- 不要执行 `cf add .` 或 `cf add -A`。工作区是整个 `$HOME`，这些命令会把缓存、密钥、
  下载内容等成千上万个无关文件加入仓库。
- 不要跟踪 SSH 私钥、云服务凭据、访问令牌、`.npmrc`、浏览器数据或其他敏感内容。提交
  前使用 `cf diff --cached` 检查暂存区。
- 新增本机覆盖文件时，同步把模式加进 `.gitignore`（当前已覆盖 `.gitconfig.local`、
  `*.local.conf`、`.config/kitty/colors.conf`）。
- `.config/kitty/colors.conf` 由 Wallust 生成，不要直接手工维护；如需调整输出，应修改
  `.config/wallust/templates/kitty.conf`。Neovim 的 `lazy-lock.json` 则会提交到仓库，
  用于固定插件版本，插件更新后应在其中体现。
- `.gitconfig` 不再包含用户信息，只保留别名和 `[include]`；身份信息写在本机
  `~/.gitconfig.local`。
- 裸仓库里 `git switch` / `cherry-pick` 这类需要工作区的命令必须带
  `--git-dir` / `--work-tree`（即通过 `cf` 执行），在 `~/.dotfiles` 里直接运行会失败。

## 目录结构

```text
$HOME
├── .gitconfig              # 别名 + [include] ~/.gitconfig.local
├── .gitignore              # 排除本机覆盖文件与生成物
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
    │   ├── kitty.conf      # 汇总 + globinclude *.local.conf
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

以下文件存在于机器上但**不在仓库中**：

```text
~/.gitconfig.local              # 本机 Git 身份
~/.config/kitty/colors.conf     # Wallust 生成
~/.config/kitty/*.local.conf    # 本机终端字体等覆盖
```
