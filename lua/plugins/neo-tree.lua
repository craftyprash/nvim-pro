-- Neo-tree: File explorer sidebar
return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  lazy = false, -- neo-tree will lazily load itself
  keys = {
    { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
    { "<leader>o", "<cmd>Neotree focus<cr>", desc = "Focus file explorer" },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    close_if_last_window = true, -- Close Neo-tree if it's the last window
    popup_border_style = "rounded",
    enable_git_status = true,
    enable_diagnostics = true,
    default_component_configs = {
      indent = {
        padding = 0,
        with_expanders = true, -- Show folder expand/collapse icons
      },
      icon = {
        folder_closed = "",
        folder_open = "",
        folder_empty = "",
      },
      git_status = {
        symbols = {
          added = "",
          modified = "",
          deleted = "",
          renamed = "➜",
          untracked = "★",
          ignored = "◌",
          unstaged = "✗",
          staged = "✓",
          conflict = "",
        },
      },
    },
    window = {
      position = "left",
      width = 30,
      mappings = {
        ["<space>"] = "none", -- Disable space (conflicts with leader key)
        ["<cr>"] = "open",
        ["l"] = "open",
        ["h"] = "close_node",
        ["v"] = "open_vsplit",
        ["s"] = "open_split",
        ["t"] = "open_tabnew",
        ["C"] = "close_all_nodes",
        ["z"] = "close_all_subnodes",
        ["R"] = "refresh",
        ["a"] = "add",
        ["d"] = "delete",
        ["r"] = "rename",
        ["y"] = "copy_to_clipboard",
        ["x"] = "cut_to_clipboard",
        ["p"] = "paste_from_clipboard",
        ["q"] = "close_window",
      },
    },
    filesystem = {
      follow_current_file = { enabled = false }, -- disable focus current file
      hijack_netrw_behavior = "open_default",
      use_libuv_file_watcher = true, -- Auto-refresh on file changes
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = false,
        hide_by_name = { ".git", "node_modules" },
      },
    },
  },
  config = function(_, opts)
    require("neo-tree").setup(opts)
    ---------------------------------------------------------------------------
    -- AUTO-OPEN NEO-TREE WHEN OPENING NVIM WITH A DIRECTORY (like LazyVim)
    ---------------------------------------------------------------------------
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local arg = vim.fn.argv(0)
        -- Check if starting with a directory
        if arg and vim.fn.isdirectory(arg) == 1 then
          vim.cmd("Neotree left reveal") -- open Neo-tree
        end
      end,
    })
  end
}
