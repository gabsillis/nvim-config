return {
  -- vim sleuth figures out shiftwidth
  {
    "tpope/vim-sleuth",
  },
  -- markdown-preview: preview markdown files
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function(plugin)
      vim.cmd.source(vim.fs.joinpath(plugin.dir, "autoload", "mkdp", "util.vim"))
      vim.fn["mkdp#util#install"]()
    end,
  },

  -- vimtex for LaTeX
  -- {
  --   "lervag/vimtex",
  --   lazy = false,
  --   init = function()
  --     -- VimTeX configuration goes here, e.g.
  --     vim.g.vimtex_view_method = "general"
  --     vim.g.vimtex_compiler_method = "latexmk"
  --   end,
  -- },
}
