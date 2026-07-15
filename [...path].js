export default async function handler(req, res) {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "server-key, content-type, accept");

    if (req.method === "OPTIONS") {
        res.status(204).end();
        return;
    }

    const full = req.url || "";
    const marker = "/api/erlc/";
    const idx = full.indexOf(marker);
    const rest = idx !== -1 ? full.slice(idx + marker.length) : full.replace(/^\//, "");
    const target = "https://api.erlc.gg/" + rest;

    const forwardHeaders = {};
    ["server-key", "content-type", "accept"].forEach((h) => {
        if (req.headers[h]) forwardHeaders[h] = req.headers[h];
    });

    let method = (req.method || "GET").toUpperCase();
    // ERLC's command endpoint only accepts POST; force it to avoid 405.
    if (/server\/command$/.test(rest)) method = "POST";

    const init = { method, headers: forwardHeaders };

    if (method !== "GET" && method !== "HEAD") {
        let body = "";
        if (typeof req.body === "string") {
            body = req.body;
        } else if (Buffer.isBuffer(req.body)) {
            body = req.body.toString("utf8");
        } else {
            body = await new Promise((resolve) => {
                let data = "";
                req.on("data", (c) => { data += c; });
                req.on("end", () => resolve(data));
            });
        }
        if (body) init.body = body;
    }

    try {
        const upstream = await fetch(target, init);
        const text = await upstream.text();
        const ct = upstream.headers.get("content-type");
        if (ct) res.setHeader("content-type", ct);
        if (upstream.status >= 400) {
            res.status(upstream.status);
            res.send(JSON.stringify({
                erlcStatus: upstream.status,
                erlcBody: text,
                debug: {
                    method: method,
                    target: target,
                    bodyLength: body ? body.length : 0,
                    hasServerKey: !!forwardHeaders["server-key"],
                    serverKeyPrefix: forwardHeaders["server-key"] ? String(forwardHeaders["server-key"]).slice(0, 6) + "..." : ""
                }
            }));
            return;
        }
        res.status(upstream.status);
        res.send(text);
    } catch (err) {
        res.status(502).json({ error: "Proxy request to ERLC failed: " + (err && err.message ? err.message : String(err)) });
    }
}
