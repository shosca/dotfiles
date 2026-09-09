// NOT managed by herdr: herdr integrations "opencode" and "opencode-tui" were
// uninstalled so they cannot overwrite this V2 port of the v11 integration,
// renamed with -v2 to stay distinct from herdr's managed paths; re-derive
// manually if herdr ships meaningful updates.
// Single-file plugin serving both the server ("." entrypoint) and the TUI
// ("./tui" entrypoint). The default export branches on ctx.ui: the TUI process
// (which inherits the herdr pane env) reports session/state and renames the
// herdr agent row to the OpenCode session topic; the shared backend service
// runs the same setup but lacks the pane env, so its branch stays inert.
// Slug rules ported from ~/.claude/hooks/herdr-agent-topic.sh.
// Original upstream: herdr opencode integration v11.
import { execFile as execFileCb } from "node:child_process";
import { promisify } from "node:util";
import net from "node:net";

const execFile = promisify(execFileCb);

export const SOURCE = "herdr:opencode";
const AGENT = "opencode";
const ROUTE_POLL_INTERVAL_MS = 100;
const STATUS_POLL_INTERVAL_MS = 1000;
const SELECTION_RETRY_DELAYS_MS = [100, 400, 1_000];

let reportSeq = Date.now() * 1000;
let requestChain = Promise.resolve();
let reportedRootSessionID;

// Track child sessions so their events cannot replace the pane's root session.
// User prompts carry the root id to preserve its identity and cross-talk guard.
const childSessions = new Map();
const CHILD_EVENT_STATES = new Map([
  ["permission.asked", "blocked"],
  ["question.asked", "blocked"],
  ["permission.replied", "working"],
  ["question.replied", "working"],
  ["question.rejected", "working"],
]);

function nextReportSeq() {
  reportSeq += 1;
  return reportSeq;
}

function sessionIDFromProperties(properties) {
  return typeof properties?.sessionID === "string" && properties.sessionID ? properties.sessionID : undefined;
}

const SESSION_STATE_BY_STATUS = new Map([
  ["idle", "idle"],
  ["active", "working"],
  ["busy", "working"],
  ["pending", "working"],
  ["retry", "working"],
  ["running", "working"],
  ["streaming", "working"],
  ["working", "working"],
]);

function stateFromSessionStatus(status) {
  const kind = typeof status === "string" ? status : status?.type;
  return typeof kind === "string" ? SESSION_STATE_BY_STATUS.get(kind.toLowerCase()) : undefined;
}

function envAvailable() {
  return process.env.HERDR_ENV === "1" && Boolean(process.env.HERDR_SOCKET_PATH) && Boolean(process.env.HERDR_PANE_ID);
}

function connectSocket(socketPath, payload) {
  return new Promise((resolve) => {
    const client = net.createConnection(socketPath, () => {
      client.write(`${JSON.stringify(payload)}\n`);
    });
    const finish = () => {
      client.destroy();
      resolve();
    };

    client.setTimeout(500, finish);
    client.on("data", finish);
    client.on("error", finish);
    client.on("end", finish);
    client.on("close", resolve);
  });
}

// Server-side reporting; serialized so concurrent events cannot interleave.
function request(method, params) {
  if (!envAvailable()) {
    return Promise.resolve();
  }
  const pending = requestChain.then(() => requestOnce(method, params));
  requestChain = pending.catch(() => {});
  return pending;
}

export function requestOnce(method, params, idPrefix = SOURCE) {
  const paneId = process.env.HERDR_PANE_ID;
  const socketPath = process.env.HERDR_SOCKET_PATH;

  if (!paneId || !socketPath) {
    return Promise.resolve();
  }

  const socketEndpoint = process.platform === "win32" ? `\\\\.\\pipe\\${socketPath}` : socketPath;
  const payload = {
    id: `${idPrefix}:${Date.now()}:${Math.floor(Math.random() * 1_000_000)
      .toString()
      .padStart(6, "0")}`,
    method,
    params: {
      pane_id: paneId,
      source: SOURCE,
      agent: AGENT,
      seq: nextReportSeq(),
      ...params,
    },
  };
  return connectSocket(socketEndpoint, payload);
}

function reportSession(sessionID) {
  if (!sessionID) {
    return Promise.resolve();
  }
  return request("pane.report_agent_session", { agent_session_id: sessionID });
}

function reportState(state, sessionID) {
  const params = { state };
  if (sessionID) {
    reportedRootSessionID = sessionID;
    params.agent_session_id = sessionID;
  }
  return request("pane.report_agent", params);
}

export async function handleEvent(event) {
  const type = event?.type;
  const properties = event?.properties ?? {};
  const sessionID = sessionIDFromProperties(properties);

  const info = properties.info;
  if (info?.id && info.parentID) {
    childSessions.set(info.id, info.parentID);
  }
  if (sessionID && childSessions.has(sessionID)) {
    const state = CHILD_EVENT_STATES.get(type);
    if (state) {
      let rootSessionID = sessionID;
      while (childSessions.has(rootSessionID)) {
        rootSessionID = childSessions.get(rootSessionID);
      }
      await reportState(state, rootSessionID);
    }
    return;
  }

  switch (type) {
    case "session.created":
      // Creation is server-global, so an attached client may own it. The
      // TUI plugin separately reports the root selected in this pane.
      reportedRootSessionID = sessionID;
      break;
    case "session.updated":
      if (sessionID && sessionID !== reportedRootSessionID) {
        await reportSession(sessionID);
      }
      break;
    case "message.updated":
      // V1 registered chat.message to mark the pane working on a user prompt;
      // a new user message in the event stream is the V2 equivalent.
      if (info?.role === "user") {
        await reportState("working", sessionID);
      }
      break;
    case "session.status": {
      const state = stateFromSessionStatus(properties.status);
      if (state) {
        await reportState(state, sessionID);
      } else {
        await reportSession(sessionID);
      }
      break;
    }
    case "tool.execute.before":
    case "tool.execute.after":
    case "permission.replied":
    case "question.replied":
    case "question.rejected":
    case "session.compacted":
      await reportState("working", sessionID);
      break;
    case "permission.asked":
    case "question.asked":
    case "session.error":
      await reportState("blocked", sessionID);
      break;
    case "session.idle":
      await reportState("idle", sessionID);
      break;
    case "session.deleted":
      break;
    default:
      break;
  }
}

// -- Agent naming (topic rename, ported from ~/.claude/hooks/herdr-agent-topic.sh)

// herdr agent names must match ^[a-z][a-z0-9_-]{0,31}$.
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

let renameChain = Promise.resolve();

// Serializes renames from multiple listeners and retries the fallback suffix
// only on agent_name_taken, matching the Claude hook's behavior.
export function renameHerdrAgent(slug) {
  const paneId = process.env.HERDR_PANE_ID;
  if (!paneId || !slug) {
    return Promise.resolve();
  }
  const pending = renameChain.then(async () => {
    for (let suffix = 0; suffix < 6; suffix += 1) {
      const candidate = suffix === 0 ? slug : `${slug.slice(0, 29)}-${suffix}`;
      try {
        await execFile("herdr", ["agent", "rename", paneId, candidate]);
        return;
      } catch (error) {
        const output = `${error?.stdout ?? ""}${error?.stderr ?? ""}`;
        if (!output.includes("agent_name_taken")) {
          return;
        }
      }
    }
  });
  renameChain = pending.catch(() => {});
  return pending;
}

// -- Server half: pane state from the shared event stream.
// The TUI half lives in ./tui.js (the CLI loader requires a separate tui
// entrypoint file to enable the TUI feature); it imports these helpers.

function setupServer(ctx) {
  if (!envAvailable()) {
    return;
  }
  const controller = new AbortController();
  void (async () => {
    for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
      await handleEvent(event).catch(() => {});
    }
  })();
  return () => controller.abort();
}


export default {
  id: "herdr.opencode",
  setup: setupServer,
};
