-- which-key: Keybinding discovery popup
return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      spec = {
        { "<leader>b", group = "buffer" },
        { "<leader>d", group = "debug" },
        { "<leader>f", group = "find/file" },
        { "<leader>g", group = "git" },
        { "<leader>gh", group = "hunks" },
        { "<leader>s", group = "search" },
        { "<leader>w", group = "window" },
        { "<leader>x", group = "quickfix" },
      },
    },
  },
}
