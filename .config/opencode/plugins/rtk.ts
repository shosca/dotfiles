import { Plugin } from "@opencode-ai/plugin"
import { execFile } from "node:child_process"

// RTK OpenCode plugin — rewrites commands to use rtk for token savings.
// Requires: rtk >= 0.23.0 in PATH.
//
// This is a thin delegating plugin: all rewrite logic lives in `rtk rewrite`,
// which is the single source of truth (src/discover/registry.rs).
// To add or change rewrite rules, edit the Rust registry — not this file.

// rtk rewrite uses non-zero exit codes as status (e.g. 1 = no rewrite
// applicable, 3 = rewrite emitted), so resolve with stdout regardless.
function run(file: string, args: string[]): Promise<string> {
  return new Promise((resolve) => {
    execFile(file, args, { timeout: 5000 }, (_err, stdout) => resolve(String(stdout)))
  })
}

function whichRtk(): Promise<boolean> {
  return new Promise((resolve) => {
    execFile("which", ["rtk"], (err) => resolve(!err))
  })
}

export const RtkPlugin = Plugin.define({
  id: "rtk",  setup: async (ctx) => {
    if (!(await whichRtk())) {
      console.warn("[rtk] rtk binary not found in PATH — plugin disabled")
      return
    }

    const registration = await ctx.tool.hook("execute.before", async (event) => {
      const tool = String(event.tool ?? "").toLowerCase()
      if (tool !== "bash" && tool !== "shell") return
      const input = event.input as { command?: unknown } | undefined
      const command = input?.command
      if (typeof command !== "string" || !command) return

      try {
        const rewritten = (await run("rtk", ["rewrite", command])).trim()
        if (rewritten && rewritten !== command && input) {
          input.command = rewritten
        }
      } catch {
        // rtk rewrite failed — pass through unchanged
      }
    })

    return registration.dispose
  },
})

export default RtkPlugin
