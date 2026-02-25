-- Editor Options
local opt = vim.opt

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0

-- Line numbers
opt.number = true
opt.relativenumber = true
opt.ruler = false

-- Mouse support
opt.mouse = "a"

-- Clipboard sync with system
opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

-- Smart case searching
opt.ignorecase = true
opt.smartcase = true

-- Split behavior
opt.splitright = true
opt.splitbelow = true

-- Undo file persistence
opt.undofile = true
opt.undolevels = 10000

-- Disable swap files
opt.swapfile = false
opt.backup = false
opt.writebackup = false

-- Sign column
opt.signcolumn = "yes"

-- Cursor line highlight
opt.cursorline = true

-- Scroll offset
opt.scrolloff = 4
opt.sidescrolloff = 8

-- Advanced options
opt.conceallevel = 2 -- Hide markup in markdown/json (0=show all, 2=hide, 3=hide completely)
opt.confirm = true -- Confirm before closing unsaved buffers
opt.fillchars = {
	foldopen = "",
	foldclose = "",
	fold = " ",
	foldsep = " ",
	diff = "╱",
	eob = " ",
}
opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = true
opt.foldmethod = "expr"
opt.foldexpr = "v:lua.vim.lsp.foldexpr()"
opt.foldtext = ""
opt.formatoptions = "jcroqlnt"
opt.laststatus = 3 -- Global statusline (single statusline for all windows)
opt.cmdheight = 0 -- Hide cmdline when not in use (shows only when typing commands)
opt.pumblend = 10 -- Popup menu transparency (0=opaque, 100=fully transparent)
opt.pumheight = 10 -- Maximum popup menu items to show
opt.smoothscroll = true -- Smooth scrolling for wrapped lines
opt.virtualedit = "block" -- Allow cursor beyond end of line in visual block mode

-- Tabs and indentation
opt.autowrite = true
opt.expandtab = true
opt.tabstop = 2
opt.shiftwidth = 2
opt.shiftround = true
opt.smartindent = true

-- Search with ripgrep
opt.grepprg = "rg --vimgrep"
opt.grepformat = "%f:%l:%c:%m"

-- Other essentials
opt.completeopt = "menu,menuone,noselect"
opt.inccommand = "nosplit"
opt.list = false
-- opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
opt.showmode = false
opt.termguicolors = true
opt.timeoutlen = 300
opt.updatetime = 200
opt.wrap = false
opt.linebreak = true
opt.wildmode = "longest:full,full"
opt.winminwidth = 5
opt.splitkeep = "screen"
opt.jumpoptions = "view"
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.spelllang = { "en" }

-- Better floating window borders
vim.o.winborder = "rounded"

-- Show diagnostics in sign column nicely
vim.diagnostic.config({
	severity_sort = true,
	underline = true,
	update_in_insert = false,
	virtual_text = {
		spacing = 2,
		prefix = "●",
	},
	float = { border = "rounded" },
})
