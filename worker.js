// Serves the pre-gzipped index.wasm with a correct Content-Encoding header.
// Godot's web export wasm is >25 MiB uncompressed, which exceeds the Workers
// static-asset per-file limit, so it is stored gzip-compressed (~10 MiB).
// The static-assets layer drops a `_headers` Content-Encoding and re-compresses
// on the fly, so we set the header here instead and pass the bytes through.
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname === "/index.wasm") {
      const res = await env.ASSETS.fetch(
        new Request(url, { headers: { "Accept-Encoding": "identity" } })
      );
      const headers = new Headers(res.headers);
      headers.set("Content-Type", "application/wasm");
      headers.set("Content-Encoding", "gzip");
      headers.set("Cache-Control", "public, max-age=31536000, immutable");
      return new Response(res.body, {
        status: res.status,
        headers,
        encodeBody: "manual",
      });
    }
    return env.ASSETS.fetch(request);
  },
};
