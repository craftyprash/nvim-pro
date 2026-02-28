-- # Debug Keymaps
-- <leader>db  → Toggle breakpoint
-- <leader>dc  → Continue/Start
-- <leader>di  → Step into
-- <leader>do  → Step over
-- <leader>dO  → Step out
-- <leader>dt  → Terminate
-- <leader>dr  → REPL toggle
-- <leader>du  → Toggle UI
-- <leader>dh  → Hover (eval under cursor)

return {
	{
		"mfussenegger/nvim-dap",
		dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
		keys = {
			{ "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
			{ "<leader>dc", function() require("dap").continue() end, desc = "Continue" },
			{ "<leader>di", function() require("dap").step_into() end, desc = "Step Into" },
			{ "<leader>do", function() require("dap").step_over() end, desc = "Step Over" },
			{ "<leader>dO", function() require("dap").step_out() end, desc = "Step Out" },
			{ "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
			{ "<leader>dr", function() require("dap").repl.toggle() end, desc = "REPL" },
			{ "<leader>du", function() require("dapui").toggle() end, desc = "Toggle UI" },
			{ "<leader>dh", function() require("dap.ui.widgets").hover() end, desc = "Hover" },
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

			-- Auto-open UI on debug start
			dap.listeners.before.attach.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.launch.dapui_config = function()
				dapui.open()
			end
			dap.listeners.before.event_terminated.dapui_config = function()
				dapui.close()
			end
			dap.listeners.before.event_exited.dapui_config = function()
				dapui.close()
			end
		end,
	},
}
