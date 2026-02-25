-- Key Mappings
local map = vim.keymap.set

local function resize_mode()
	print("-- RESIZE MODE (h,j,k,l to resize, Esc to exit) --")
	while true do
		local char = vim.fn.getchar()
		local key = vim.fn.nr2char(char)

		if key == "h" then
			-- If at left edge, shrink right; otherwise grow left
			if vim.fn.winnr() == vim.fn.winnr("h") then
				vim.cmd("vertical resize -2")
			else
				vim.cmd("vertical resize +2")
			end
		elseif key == "j" then
			-- If at bottom edge, shrink up; otherwise grow down
			if vim.fn.winnr() == vim.fn.winnr("j") then
				vim.cmd("resize -2")
			else
				vim.cmd("resize +2")
			end
		elseif key == "k" then
			-- If at top edge, shrink down; otherwise grow up
			if vim.fn.winnr() == vim.fn.winnr("k") then
				vim.cmd("resize -2")
			else
				vim.cmd("resize +2")
			end
		elseif key == "l" then
			-- If at right edge, shrink left; otherwise grow right
			if vim.fn.winnr() == vim.fn.winnr("l") then
				vim.cmd("vertical resize -2")
			else
				vim.cmd("vertical resize +2")
			end
		else
			break
		end
		vim.cmd("redraw")
	end
	print("-- EXIT RESIZE MODE --")
end

-- Better up/down (handle wrapped lines)
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window" })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window" })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- Terminal mode escape
map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

-- Save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

-- Buffer navigation
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to other buffer" })

-- Window resizing
map("n", "<leader>wr", resize_mode, { desc = "Enter continuous resize mode" })
-- Split window shortcuts
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right" })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below" })
map("n", "<leader>wx", "<C-W>c", { desc = "Delete window" })

-- Move lines up/down (Alt+j/k or J/K in visual mode)
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move line down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move line up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move line down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move line up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move lines down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move lines up" })
-- Alternative: J/K in visual mode (since Alt might not work on macOS)
map("v", "J", ":m '>+1<cr>gv=gv", { desc = "Move lines down" })
map("v", "K", ":m '<-2<cr>gv=gv", { desc = "Move lines up" })

-- Better indenting
map("x", "<", "<gv", { desc = "Indent left" })
map("x", ">", ">gv", { desc = "Indent right" })

-- Undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- Better search (center and unfold)
map("n", "n", "nzzzv", { desc = "Next search result" })
map("n", "N", "Nzzzv", { desc = "Prev search result" })

-- Lazy plugin manager
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- Quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- New file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New file" })

-- Quickfix and location list
map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })
map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
