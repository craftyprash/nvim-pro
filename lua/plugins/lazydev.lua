-- lazydev.nvim: proper types/completion for the Neovim Lua API when editing
-- this config (vim.*, vim.uv, and loaded plugin modules like snacks).
return {
  "folke/lazydev.nvim",
  ft = "lua",
  opts = {
    library = {
      -- Load luv types when the `vim.uv` word is found
      { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      "snacks.nvim",
    },
  },
}
