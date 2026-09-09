// TUI-side tmux rename plugin: renames the tmux window/session to the OpenCode
// session topic slug, polling the selected session like the herdr plugin does.
// Runs in the TUI process, which inherits the tmux env.

import { renameTmux, slugifyTitle } from "./index.js";

const STATUS_POLL_INTERVAL_MS = 1000;

export default {
  id: "tmux.opencode.session-topic",
  setup(context) {
    if (!process.env.TMUX) {
      return;
    }

    let lastRenameSlug;

    const renameToTopic = async () => {
      try {
        const route = context.ui.router.current();
        const sessionID = route?.params?.sessionID ?? route?.sessionID;
        const session = typeof sessionID === "string" ? context.data.session.get(sessionID) : undefined;
        if (!session || session.parentID) {
          return;
        }
        const slug = slugifyTitle(session?.title);
        if (!slug || slug === lastRenameSlug) {
          return;
        }
        lastRenameSlug = slug;
        await renameTmux(slug);
      } catch {
        // Renaming is best-effort; tmux keeps the prior name on failure.
      }
    };

    void renameToTopic();
    const poll = setInterval(() => void renameToTopic(), STATUS_POLL_INTERVAL_MS);
    return () => clearInterval(poll);
  },
}
