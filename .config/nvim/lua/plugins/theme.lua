-- 主题透明度：nvim 背景设为 NONE，透出终端（kitty background_opacity 0.87）的壁纸
return {
  {
    "folke/tokyonight.nvim",
    opts = {
      -- 不设置 Normal 的 bg，编辑器区域透明
      transparent = true,
      styles = {
        sidebars = "transparent", -- snacks explorer 之类的侧栏
        floats = "transparent", -- 浮窗（snacks picker / which-key / noice 等）
      },
    },
  },
}
