// tmux companion to the herdr plugin: renames the tmux session to the OpenCode
// session topic slug (only when it holds one window, so a shared session never
// takes the name of a single task). Windows are left alone.
// Runs in the TUI process, which inherits the tmux env the shared background
// service does not have; the server default export stays inert.

import { execFile as execFileCb } from "node:child_process";
import { promisify } from "node:util";

const execFile = promisify(execFileCb);

export function slugifyTitle(title) {
  if (typeof title !== "string") {
    return undefined;
  }
  let slug = title
    .toLowerCase()
    .replace(/[^a-z0-9_-]/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-+|-+$/g, "");
  slug = slug.replace(/^[^a-z]+/, "");
  if (slug.length > 32) {
    slug = slug.slice(0, 32);
    const cut = slug.lastIndexOf("-");
    if (cut > 0) {
      slug = slug.slice(0, cut);
    }
    slug = slug.replace(/-+$/g, "");
  }
  if (!/^[a-z][a-z0-9_-]{0,31}$/.test(slug)) {
    return undefined;
  }
  return slug;
}

// tmux window names share the herdr slug constraints, so reuse slugifyTitle.
let renameChain = Promise.resolve();

export function renameTmux(slug) {
  const pane = process.env.TMUX_PANE;
  if (!pane || !slug) {
    return Promise.resolve();
  }
  const pending = renameChain.then(async () => {
    try {
      const windows = await execFile("tmux", ["display-message", "-p", "-t", pane, "#{session_windows}"]);
      // Rename the session only when this window is its only one, so a shared
      // session never takes the name of a single task.
      if (windows.stdout.trim() === "1") {
        const name = await execFile("tmux", ["display-message", "-p", "-t", pane, "#S"]);
        const session = name.stdout.trim();
        if (session && session !== slug) {
          await execFile("tmux", ["rename-session", "-t", session, slug]).catch(() => {});
        }
      }
    } catch {
      // Renaming is best-effort; tmux keeps the prior name on failure.
    }
  });
  renameChain = pending.catch(() => {});
  return pending;
}

export default {
  id: "tmux.opencode.session-topic",
  // Server-side instance is inert; the rename logic runs in the TUI (tui.js).
  setup() {},
};
