/** Minimal typings for Supabase Edge (Deno) when using the workspace TypeScript server. */
declare const Deno: {
  env: {
    get(key: string): string | undefined;
  };
  serve(handler: (request: Request) => Response | Promise<Response>): void;
};
