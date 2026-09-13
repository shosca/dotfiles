/**
 * llama-swap plugin for OpenCode 2 (V2 plugin API)
 *
 * Auto-discovers models from a llama-swap instance and injects them into the
 * catalog under the configured provider. Refreshes every 30 seconds, matching
 * the built-in opencode.provider.lmstudio plugin's behavior: hash-compare the
 * fetched list, reload the catalog only on change.
 *
 * The plugin owns the provider's model list: models removed from llama-swap
 * are also removed from the catalog, and config-defined models for this
 * provider are overwritten.
 *
 * Ported from CoryBR/llamaswap-opencode-plugin (V1 API).
 */

// No `@opencode-ai/plugin` import: this file is symlinked into
// ~/.config/opencode/plugins/ from dotfiles, and Bun resolves bare imports
// from the realpath, where no node_modules exists. The loader accepts a
// plain { id, setup } default export (Plugin.define is identity anyway).

const FETCH_TIMEOUT = 5000;
const DEFAULT_OUTPUT_LIMIT = 65536;
const DEFAULT_CONTEXT_LIMIT = 32768;
const REFRESH_INTERVAL_MS = 30_000;

interface LlamaSwapMeta {
  context?: string;
  effective_context_per_slot?: string;
  training_context?: string;
  implementation?: string;
  size?: string;
  quantization?: string;
  multimodal?: boolean;
  thinking?: boolean;
  tool_calling?: boolean;
  [key: string]: unknown;
}

interface LlamaSwapModel {
  id: string;
  name?: string;
  description?: string;
  meta?: { llamaswap?: LlamaSwapMeta };
}

function parseContextLimit(meta: LlamaSwapMeta): number {
  // 1. Exact per-slot limit
  if (meta.effective_context_per_slot) {
    const val = parseInt(meta.effective_context_per_slot, 10);
    if (!isNaN(val) && val > 0) return val;
  }

  // 2. training_context numeric field (usually matches the -c flag)
  if (meta.training_context) {
    const val = parseInt(meta.training_context, 10);
    if (!isNaN(val) && val > 0) return val;
  }

  const ctxStr = meta.context || "";

  // 3. Parse "configured" value: "32K configured / 128K trained" -> 32768
  const configuredMatch = ctxStr.match(/(\d+)[Kk]\s*configured/);
  if (configuredMatch) {
    return parseInt(configuredMatch[1], 10) * 1024;
  }

  // 4. Any "K" value from context string as last resort
  const anyK = ctxStr.match(/(\d+)[Kk]/);
  if (anyK) {
    return parseInt(anyK[1], 10) * 1024;
  }

  return DEFAULT_CONTEXT_LIMIT;
}

async function fetchJSON<T>(baseUrl: string, path: string, options?: RequestInit): Promise<T> {
  const resp = await fetch(`${baseUrl}${path}`, {
    ...options,
    signal: AbortSignal.timeout(FETCH_TIMEOUT),
  });
  return resp.json() as Promise<T>;
}

export default {
  id: "llamaswap",
  async setup(ctx) {
    const url =
      (ctx.options?.url as string) || process.env.LLAMASWAP_URL || "http://localhost:8090";
    const providerID =
      (ctx.options?.provider as string) || process.env.LLAMASWAP_PROVIDER || "llama-swap";

    let models: LlamaSwapModel[] = [];
    let hash = "";

    // Idempotent transform, replayed on every catalog reload. No-ops while the
    // first fetch hasn't succeeded yet (retry happens on the refresh timer).
    await ctx.catalog.transform((catalog) => {
      if (models.length === 0) return;

      // Drop models llama-swap no longer serves (provider record is absent on
      // first materialization, which is fine — nothing to remove then)
      const provider = catalog.provider.get(providerID);
      if (provider) {
        for (const existing of provider.models.values()) {
          if (!models.some((m) => m.id === existing.id)) {
            catalog.model.remove(providerID, existing.id);
          }
        }
      }

      for (const item of models) {
        const meta = item.meta?.llamaswap || {};
        const contextLimit = parseContextLimit(meta);

        catalog.model.update(providerID, item.id, (model) => {
          model.name = item.name || item.id;
          model.limit = { context: contextLimit, output: DEFAULT_OUTPUT_LIMIT };
          model.capabilities = {
            tools: meta.tool_calling === true,
            input: meta.multimodal ? ["text", "image"] : ["text"],
            output: meta.thinking ? ["text", "reasoning"] : ["text"],
          };
        });
      }
    });

    const refresh = async () => {
      const data = await fetchJSON<{ data: LlamaSwapModel[] }>(url, "/v1/models");
      const next = JSON.stringify(data.data);
      if (next === hash) return;
      models = data.data;
      hash = next;
      await ctx.catalog.reload();
    };

    // Initial fetch; failures are logged and swallowed so plugin load never
    // blocks opencode. The interval retries until llama-swap is reachable.
    await refresh().catch((err) => {
      console.error(`[llamaswap] Failed to fetch models from ${url}: ${err}`);
    });

    const timer = setInterval(() => {
      void refresh().catch((err) => {
        console.error(`[llamaswap] Model refresh failed: ${err}`);
      });
    }, REFRESH_INTERVAL_MS);

    // -- runtime tools ---------------------------------------------------

    await ctx.tool.transform((draft) => {
      draft.add({
        name: "llamaswap_models",
        description:
          "List all available models on the llama-swap server with metadata (size, quantization, context, backend)",
        input: { type: "object", properties: {}, additionalProperties: false },
        options: { namespace: "llamaswap" },
        execute: async () => {
          const data = await fetchJSON<{ data: LlamaSwapModel[] }>(url, "/v1/models");
          const lines: string[] = [];
          for (const m of data.data) {
            const meta = m.meta?.llamaswap || {};
            const parts = [m.id];
            if (m.name && m.name !== m.id) parts.push(`"${m.name}"`);
            if (meta.size) parts.push(`size=${meta.size}`);
            if (meta.quantization) parts.push(`quant=${meta.quantization}`);
            if (meta.context) parts.push(`ctx=${meta.context}`);
            if (meta.implementation) parts.push(`backend=${meta.implementation}`);
            const caps: string[] = [];
            if (meta.multimodal) caps.push("multimodal");
            if (meta.thinking) caps.push("thinking");
            if (meta.tool_calling) caps.push("tool_calling");
            if (caps.length) parts.push(`caps=[${caps.join(",")}]`);
            lines.push(parts.join(" | "));
          }
          return {
            content: [
              {
                type: "text",
                text: `${data.data.length} models available:\n\n${lines.join("\n")}`,
              },
            ],
          };
        },
      });

      draft.add({
        name: "llamaswap_status",
        description: "Show currently running/loaded models on the llama-swap server",
        input: { type: "object", properties: {}, additionalProperties: false },
        options: { namespace: "llamaswap" },
        execute: async () => {
          const data = await fetchJSON<{ running: unknown[] }>(url, "/running");
          if (!data.running || data.running.length === 0) {
            return { content: [{ type: "text", text: "No models currently loaded." }] };
          }
          return {
            content: [
              {
                type: "text",
                text: `Running models:\n${JSON.stringify(data.running, null, 2)}`,
              },
            ],
          };
        },
      });

      draft.add({
        name: "llamaswap_unload",
        description: "Unload the current model from the llama-swap server to free VRAM",
        input: { type: "object", properties: {}, additionalProperties: false },
        options: { namespace: "llamaswap" },
        execute: async () => {
          const resp = await fetch(`${url}/unload`, {
            signal: AbortSignal.timeout(FETCH_TIMEOUT),
          });
          if (resp.ok) {
            return { content: [{ type: "text", text: "Model unloaded successfully." }] };
          }
          return {
            content: [
              {
                type: "text",
                text: `Unload failed: HTTP ${resp.status} ${resp.statusText}`,
              },
            ],
          };
        },
      });
    });

    return () => clearInterval(timer);
  },
};
