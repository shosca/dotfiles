// Compatibility shim: context-mode 1.0.169 exports { id, server } but
// OpenCode 2.0.x requires a default plugin object with setup() too.
import contextModePlugin from "context-mode";

export default {
  ...contextModePlugin,
  setup() {},
};
