---
name: litellm
description: Call models the way Affan's projects do, through the memfold LiteLLM proxy (https://litellm.memfold.ai/v1, key in LITELLM_KEY), OpenAI-compatible, never a local model server and never a vendor SDK baked in. Covers listing the live models, chat and responses calls, pi and Codex config, reasoning effort, and proxy errors. Use whenever code or config calls an LLM, picks or changes a model, adds an AI feature, wires an agent to a provider, hits a model or proxy error, or he mentions litellm, the proxy, model names, "use my litellm key", or "we don't use ollama".
---

# LiteLLM

"We don't use ollama or shit like that. We use our litellm stuff." 16 repos and 336 prompts route their models
through one proxy.

## Facts (checked 2026-11-08)

- **Base URL `https://litellm.memfold.ai/v1`, OpenAI-compatible:** `/models`, `/chat/completions`, `/responses`.
- **The key is `LITELLM_KEY`, exported in `~/.zshrc`.** Code reads it from the environment by name. Never put its
  value in code, config, logs or replies. Configs that take a key name take the bare name (pi's `models.json` has
  `"apiKey": "LITELLM_KEY"`, no `$`). CI gets a secret of the same name.
- **The model list changes, so list it before choosing:**
  ```sh
  curl -s https://litellm.memfold.ai/v1/models -H "Authorization: Bearer $LITELLM_KEY" | jq -r '.data[].id'
  ```
  On 2026-11-08 the list was:
  - `gpt-6.1-terra`, `gpt-6.1-sol`, `gpt-6-astra`
  - `claude-sonnet-5-5`, `bedrock-claude-{opus,sonnet,haiku}-5-5`
  - `deepseek-v4.1-flash`, `deepseek-ai/DeepSeek-V4.1-Flash-1017-Fast`
  - `gemma-4-31b`, `cerebras/qwen-3.8-27b`, `gemini-embedding-2`

  Names in older repos and in pi's config (`gpt-5.6-sol`, `gpt-5.6-terra`, `claude-opus-4-8`) are gone.
- **A listed model can still be down.** `400 … no healthy deployments for this model` means that deployment is
  unhealthy right now; it doesn't mean the key is wrong. It happened to `claude-haiku-5-5` on 2026-11-08. Pick
  another model or tell Affan.
- **`gemma-4-31b` is the self-hosted box and is slow to answer.** A 30 s call to it timed out on 2026-11-08, while
  `deepseek-v4.1-flash` answered in 3.8 s.

## Calling it

- One OpenAI-compatible request, with the model name from config: an env var with the product prefix, e.g.
  `CUA_AGENT_MODEL`. A model name is never a literal scattered through code.
- Use what the language already has: `fetch` in TS, `ureq` in Rust, `urllib` in Python, or the `openai` package with
  `base_url` set where the repo already uses it. No provider SDKs (`@anthropic-ai/sdk`, `@ai-sdk/anthropic`) for
  proxy calls, and no provider lock-in.
  ```sh
  curl -s https://litellm.memfold.ai/v1/chat/completions -H "Authorization: Bearer $LITELLM_KEY" \
    -H 'Content-Type: application/json' -d '{"model":"deepseek-v4.1-flash","messages":[{"role":"user","content":"hi"}]}'
  ```
- Reasoning goes in `reasoning_effort` (`low` to `xhigh`). The proxy refused `minimal` for `gpt-5.6-sol`, so try the
  level on the model you use before relying on it.
- A streamed answer read to its end keeps the connection alive for the next call (creator-agent measured 0.5 s on a
  kept connection against 1.0 s on a new one). Keep one client per process.

## Wiring tools

- **pi:** `~/.pi/agent/models.json`, provider `litellm` with `api: openai-completions`, the base URL above,
  `apiKey: "LITELLM_KEY"`, and its models. The list there goes stale: compare it with `/models`. A second provider,
  `litellm-claude`, names `LITELLM_CLAUDE_KEY`, which isn't exported in `~/.zshrc`.
- **Codex:** `~/.codex/config.toml`, `[model_providers.litellm]` with the base URL above and
  `wire_api = "responses"`. Its key comes from an auth command that reads a key file.
- **CI:** `LITELLM_KEY` as a repo secret, like creator-agent's `codex-review.yml`.
- **Beside the proxy:** Baseten (`BASETEN_API_KEY`, `https://inference.baseten.co/v1`) for fast DeepSeek and GLM in
  mini-cua and pi. Use it only where the repo already does.
