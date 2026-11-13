return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        clangd = {},

        neocmake = {},

        pyright = {},

        emmet_language_server = {},

        marksman = {},
      },
    },
  },

  -- markdown 不跑 markdownlint-cli2（nvim-lint），避免满屏警告
  -- LSP(marksman) 仍然附着，只是诊断在 autocmds.lua 里被关掉了
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.markdown = nil
      opts.linters_by_ft["markdown.mdx"] = nil
    end,
  },
}
