-- Colorschemes
--
-- Active theme: kanagawa (rebelot/kanagawa.nvim), "wave" variant.
-- Warm, muted, low-saturation palette that's easy on the eyes for late-night
-- coding; unlike onedark it does NOT paint variables/parameters red, so
-- parameter-heavy code (Java/Quarkus) stays calm instead of looking error-filled.
-- Matches the Ghostty "Kanagawa Wave" theme + Herdr's "kanagawa" theme (bg
-- #1f1f28), so Ghostty + Herdr + Neovim share one palette.
-- The alternatives below are lazy-loaded; preview/switch via `<leader>sC`.
return {
  {
    "rebelot/kanagawa.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      theme = "wave", -- wave (default), dragon (darker), lotus (light)
      transparent = false,
      dimInactive = false,
      commentStyle = { italic = false }, -- set italic = true for softer comments
    },
    config = function(_, opts)
      require("kanagawa").setup(opts)
      vim.cmd.colorscheme("kanagawa-wave")
    end,
  },

  -- Alternatives (lazy-loaded; previewable via <leader>sC)
  { "navarasu/onedark.nvim", lazy = true, opts = { style = "dark", transparent = false } },
  { "folke/tokyonight.nvim", lazy = true, opts = { style = "night", transparent = false } },
  { "catppuccin/nvim", name = "catppuccin", lazy = true, opts = { flavour = "mocha" } },
  { "EdenEast/nightfox.nvim", lazy = true, opts = { options = { transparent = false } } },
  { "rose-pine/neovim", name = "rose-pine", lazy = true, opts = {} },
}
