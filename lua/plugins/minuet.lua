-- minuet-ai.nvim: local LLM code autocomplete (ghost text) via Ollama.
--
-- Tier-1 assistant: fast, free, private, offline inline suggestions from a small
-- coder model. This is where a local model actually shines. Reasoning-heavy work
-- (refactors, debugging, architecture) still goes to Claude via claudecode.nvim
-- — don't expect this to match it.
--
-- Requires a running Ollama with the FIM model:  ollama pull qwen2.5-coder:7b
-- Fails gracefully (no ghost text) if Ollama isn't up, so it never blocks editing.
--
-- Ghost-text keys (insert mode, while a suggestion is shown):
--   <A-a> accept all   <A-l> accept line   <A-z> accept N lines
--   <A-]> / <A-[> next / prev   <A-e> dismiss
return {
  "milanglacier/minuet-ai.nvim",
  event = "InsertEnter",
  config = function()
    require("minuet").setup({
      provider = "openai_fim_compatible",
      n_completions = 1, -- one suggestion keeps the local model light
      context_window = 512, -- raise later if the M4 Pro has headroom
      notify = "warn", -- don't spam if Ollama is down
      provider_options = {
        openai_fim_compatible = {
          api_key = "TERM", -- Ollama needs no key; any existing env var name works
          name = "Ollama",
          end_point = "http://localhost:11434/v1/completions",
          model = "qwen2.5-coder:7b",
          optional = {
            max_tokens = 56,
            top_p = 0.9,
          },
        },
      },
      virtualtext = {
        -- Ghost-text suggestions in code buffers (skip prose/markdown).
        auto_trigger_ft = {
          "lua",
          "python",
          "go",
          "rust",
          "java",
          "javascript",
          "typescript",
          "typescriptreact",
          "javascriptreact",
          "sh",
          "bash",
          "json",
          "yaml",
          "html",
          "css",
        },
        keymap = {
          accept = "<A-a>",
          accept_line = "<A-l>",
          accept_n_lines = "<A-z>",
          prev = "<A-[>",
          next = "<A-]>",
          dismiss = "<A-e>",
        },
      },
    })
  end,
}
