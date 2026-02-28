-- # Debug Keymaps (VSCode/Zed style)
-- F5       → Continue/Start
-- S-F5     → Terminate
-- F9       → Toggle breakpoint
-- F10      → Step over
-- F11      → Step into
-- S-F11    → Step out
-- <leader>du → Toggle UI
-- <leader>de → Eval (hover)

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
		keys = {
			{ "<F5>", function() require("dap").continue() end, desc = "Continue" },
			{ "<S-F5>", function() require("dap").terminate() end, desc = "Terminate" },
			{ "<F9>", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
			{ "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
			{ "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
			{ "<S-F11>", function() require("dap").step_out() end, desc = "Step Out" },
			{ "<leader>du", function() require("dapui").toggle() end, desc = "Toggle UI" },
			{ "<leader>de", function() require("dap.ui.widgets").hover() end, desc = "Eval" },
		},
		config = function()
			local dap = require("dap")

			-- Breakpoint signs
			vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapStopped", { text = "→", texthl = "DiagnosticWarn" })

			-- Go (delve)
			dap.adapters.delve = {
				type = "server",
				port = "${port}",
				executable = {
					command = "dlv",
					args = { "dap", "-l", "127.0.0.1:${port}" },
				},
			}
			dap.configurations.go = {
				{
					type = "delve",
					name = "Debug",
					request = "launch",
					program = "${file}",
				},
				{
					type = "delve",
					name = "Debug (Arguments)",
					request = "launch",
					program = "${file}",
					args = function()
						return vim.split(vim.fn.input("Args: "), " ")
					end,
				},
				{
					type = "delve",
					name = "Debug Package",
					request = "launch",
					program = "${fileDirname}",
				},
			}

			-- Rust (codelldb)
			dap.adapters.codelldb = {
				type = "server",
				port = "${port}",
				executable = {
					command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
					args = { "--port", "${port}" },
				},
			}
			dap.configurations.rust = {
				{
					type = "codelldb",
					name = "Debug",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
					end,
					cwd = "${workspaceFolder}",
					stopOnEntry = false,
				},
			}

			-- Setup dap-ui
			local dapui = require("dapui")
			dapui.setup({
				layouts = {
					{
						elements = {
							{ id = "scopes", size = 0.4 },
							{ id = "breakpoints", size = 0.2 },
							{ id = "stacks", size = 0.4 },
						},
						size = 40,
						position = "left",
					},
					{
						elements = {
							{ id = "repl", size = 0.5 },
							{ id = "console", size = 0.5 },
						},
						size = 10,
						position = "bottom",
					},
				},
			})

			-- Auto-open/close UI
			dap.listeners.before.attach.dapui_config = function() dapui.open() end
			dap.listeners.before.launch.dapui_config = function() dapui.open() end
			dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
			dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
		end,
	},
}
