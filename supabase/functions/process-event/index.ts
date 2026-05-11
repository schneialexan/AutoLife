import { handleProcessEvent } from "./handler.ts";

Deno.serve((req) => handleProcessEvent(req));
