-- Auto Commands
local function augroup(name)
  return vim.api.nvim_create_augroup("crafty_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Check for file changes on focus
vim.api.nvim_create_autocmd({ "FocusGained", "TermClose", "TermLeave" }, {
  group = augroup("checktime"),
  callback = function()
    if vim.bo.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})

-- Resize splits on window resize
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    local current_tab = vim.fn.tabpagenr()
    vim.cmd("tabdo wincmd =")
    vim.cmd("tabnext " .. current_tab)
  end,
})

-- Go to last location when opening buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].last_loc then
      return
    end
    vim.b[buf].last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Close certain filetypes with 'q'
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("close_with_q"),
  pattern = {
    "help",
    "lspinfo",
    "checkhealth",
    "qf",
    "notify",
    "startuptime",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<cr>", {
      buffer = event.buf,
      silent = true,
      desc = "Quit buffer",
    })
  end,
})

-- Wrap and spell check for text files
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "text", "plaintex", "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto create parent directories on save
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  group = augroup("auto_create_dir"),
  callback = function(event)
    if event.match:match("^%w%w+:[\\/][\\/]") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
  end,
})

-- Fix conceallevel for JSON files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
  end,
})

-- Smart directory detection: set cwd to project root or directory argument
vim.api.nvim_create_autocmd("VimEnter", {
  group = augroup("smart_cwd"),
  callback = function()
    local arg = vim.fn.argv(0)
    if arg == "" then
      return
    end

    -- Handle oil:// URLs from Oil.nvim
    local dir
    if arg:match("^oil://") then
      dir = arg:gsub("^oil://", "")
      -- Remove trailing slash
      dir = dir:gsub("/$", "")
    elseif vim.fn.isdirectory(arg) == 1 then
      dir = vim.fn.fnamemodify(arg, ":p")
    elseif vim.fn.filereadable(arg) == 1 then
      dir = vim.fn.fnamemodify(arg, ":p:h")
    else
      return
    end

    -- Search for .git directory up the tree
    local function find_git_root(path)
      local git_path = path .. "/.git"
      if vim.fn.isdirectory(git_path) == 1 or vim.fn.filereadable(git_path) == 1 then
        return path
      end
      local parent = vim.fn.fnamemodify(path, ":h")
      if parent == path then
        return nil
      end
      return find_git_root(parent)
    end

    local root = find_git_root(dir) or dir
    vim.schedule(function()
      vim.cmd.cd(root)
    end)
  end,
})
