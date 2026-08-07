-- herdr-splits.nvim: seamless navigation + resize across Neovim splits and
-- herdr panes with the same Ctrl+h/j/k/l (and Alt+h/j/k/l to resize).
--
-- Replaces vim-tmux-navigator, which only understood tmux. This is the two-sided
-- integration: the herdr plugin (herdr plugin install lmilojevicc/herdr-splits.nvim)
-- intercepts Ctrl-hjkl, detects whether the focused pane runs Neovim, and forwards
-- the key here when it does; this Lua side moves the nvim window and hands control
-- back to herdr at a split edge. See ~/.config/herdr/config.toml [[keys.command]].
--
-- `cond` keeps it inactive outside herdr (e.g. standalone nvim, IDE terminals),
-- where the plain <C-w>h/j/k/l maps in config/keymaps.lua take over instead.
return {
  "lmilojevicc/herdr-splits.nvim",
  cond = vim.env.HERDR_ENV == "1",
  event = "VeryLazy",
  opts = {
    default_amount = 0.03, -- herdr pane resize ratio
    neovim_amount = 3, -- nvim window resize cells
    at_edge = "wrap",
    ignored_buftypes = { "nofile", "quickfix", "prompt", "help", "terminal" },
    ignored_filetypes = {
      "neo-tree",
      "snacks_dashboard",
      "snacks_explorer",
      "snacks_picker",
      "dbout",
      "aerial",
      "Outline",
      "Trouble",
      "qf",
    },
    move_cursor_same_row = false,
    unzoom_on_nav = true,
    nav_at_edge = "wrap",
  },
  keys = {
    -- Navigate (normal + terminal mode, so you can move OUT of :terminal too).
    -- Terminal-mode variants leave terminal mode first, then move.
    { "<C-h>", function() require("herdr-splits").move_cursor_left() end, desc = "Navigate left" },
    { "<C-j>", function() require("herdr-splits").move_cursor_down() end, desc = "Navigate down" },
    { "<C-k>", function() require("herdr-splits").move_cursor_up() end, desc = "Navigate up" },
    { "<C-l>", function() require("herdr-splits").move_cursor_right() end, desc = "Navigate right" },
    { "<C-h>", [[<C-\><C-n><cmd>lua require("herdr-splits").move_cursor_left()<cr>]], mode = "t", desc = "Navigate left" },
    { "<C-j>", [[<C-\><C-n><cmd>lua require("herdr-splits").move_cursor_down()<cr>]], mode = "t", desc = "Navigate down" },
    { "<C-k>", [[<C-\><C-n><cmd>lua require("herdr-splits").move_cursor_up()<cr>]], mode = "t", desc = "Navigate up" },
    { "<C-l>", [[<C-\><C-n><cmd>lua require("herdr-splits").move_cursor_right()<cr>]], mode = "t", desc = "Navigate right" },
    -- Resize (Alt+h/j/k/l; needs macos-option-as-alt = true in Ghostty)
    { "<M-h>", function() require("herdr-splits").resize_left() end, desc = "Resize left" },
    { "<M-j>", function() require("herdr-splits").resize_down() end, desc = "Resize down" },
    { "<M-k>", function() require("herdr-splits").resize_up() end, desc = "Resize up" },
    { "<M-l>", function() require("herdr-splits").resize_right() end, desc = "Resize right" },
  },
}
