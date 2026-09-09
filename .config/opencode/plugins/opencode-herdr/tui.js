// TUI entrypoint for the herdr opencode plugin. The CLI loader enables the
// TUI feature from this separate file; all shared logic (socket reporting,
// event handling, slugs, renames) lives in ./index.js, imported here.
// Runs in the TUI process, which inherits the herdr pane env the shared
// background service does not have.

import {
  SOURCE,
  handleEvent,
  renameHerdrAgent,
  requestOnce,
  slugifyTitle,
} from "./index.js";

const ROUTE_POLL_INTERVAL_MS = 100;
const STATUS_POLL_INTERVAL_MS = 1000;
const SELECTION_RETRY_DELAYS_MS = [100, 400, 1_000];

function routeSessionID(route) {
  // Loose check: route shape varies between beta releases.
  return route?.params?.sessionID ?? route?.sessionID;
}

export default {
  id: "herdr.opencode.session-selection",
  setup(ctx) {
    if (process.env.HERDR_ENV !== "1" || !process.env.HERDR_SOCKET_PATH || !process.env.HERDR_PANE_ID) {
      return;
    }

  let selectedSessionID;
    let retryIndex = 0;
    let nextReportAt = 0;
    let reportPending = false;
    let lastRenameSlug;

    const syncSelectedSession = async () => {
      const route = ctx.ui.router.current();
      const sessionID = routeSessionID(route);
      const session = typeof sessionID === "string" && sessionID ? ctx.data.session.get(sessionID) : undefined;
      if (!session || session.parentID) {
        selectedSessionID = undefined;
        retryIndex = 0;
        nextReportAt = 0;
        return;
      }
      if (sessionID !== selectedSessionID) {
        selectedSessionID = sessionID;
        retryIndex = 0;
        nextReportAt = 0;
      }
      if (reportPending || Date.now() < nextReportAt) {
        return;
      }

      const reportingSessionID = sessionID;
      reportPending = true;
      try {
        await requestOnce("pane.report_agent_session", {
          agent_session_id: reportingSessionID,
          session_start_source: "select",
        }, `${SOURCE}:tui`);
      } catch {
        // Best-effort reporting retries below while the selected route remains active.
      } finally {
        reportPending = false;
      }
      if (selectedSessionID !== reportingSessionID) {
        retryIndex = 0;
        nextReportAt = 0;
        return;
      }
      const retryDelay = SELECTION_RETRY_DELAYS_MS[retryIndex];
      retryIndex += 1;
      nextReportAt = retryDelay === undefined ? Number.POSITIVE_INFINITY : Date.now() + retryDelay;
    };

    const syncSelectedStatus = async () => {
      if (!selectedSessionID) {
        return;
      }
      try {
        const status = ctx.data.session.status(selectedSessionID);
        const state =
          typeof status === "string"
            ? { type: status }
            : (status?.type ?? status?.state ?? status?.status) != null
              ? status
              : undefined;
        if (state) {
          // Reuse the shared status→state mapping by faking a status event.
          await handleEvent({
            type: "session.status",
            properties: { sessionID: selectedSessionID, status: state },
          });
        }
      } catch {
        // Status API may not exist in this beta; events cover the rest.
      }
    };

    const renameToTopic = async () => {
      if (!selectedSessionID) {
        return;
      }
      try {
        const session = ctx.data.session.get(selectedSessionID);
        const slug = slugifyTitle(session?.title);
        if (!slug || slug === lastRenameSlug) {
          return;
        }
        lastRenameSlug = slug;
        await renameHerdrAgent(slug);
      } catch {
        // Renaming is best-effort; herdr keeps the prior name on failure.
      }
    };

    void syncSelectedSession();
    const routePoll = setInterval(() => void syncSelectedSession(), ROUTE_POLL_INTERVAL_MS);
    const statusPoll = setInterval(() => {
      void syncSelectedStatus();
      void renameToTopic();
    }, STATUS_POLL_INTERVAL_MS);
    const stopEvents = ctx.data.listen(({ details }) => handleEvent(details));
    return () => {
      clearInterval(routePoll);
      clearInterval(statusPoll);
      stopEvents();
    };
  },
};
