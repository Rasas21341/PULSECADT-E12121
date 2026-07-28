module.exports = async function handler(req, res) {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "content-type");

    if (req.method === "OPTIONS") {
        res.status(204).end();
        return;
    }

    if (req.method !== "POST") {
        res.status(405).json({ error: "Method not allowed" });
        return;
    }

    let payload = {};
    try {
        payload = typeof req.body === "string" ? JSON.parse(req.body) : (req.body || {});
    } catch (e) {
        payload = {};
    }

    const webhook = payload.webhook || "";
    if (!/^https:\/\/discord(app)?\.com\/api\/webhooks\//.test(webhook)) {
        res.status(400).json({ error: "Invalid webhook URL" });
        return;
    }

    const message = {
        content: payload.content || "PulseCAD notification",
        username: payload.username || "PulseCAD"
    };
    if (payload.avatar_url) message.avatar_url = payload.avatar_url;

    try {
        const upstream = await fetch(webhook, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify(message)
        });
        const text = await upstream.text();
        res.status(upstream.status);
        res.setHeader("content-type", "application/json");
        res.send(text || JSON.stringify({ ok: upstream.ok }));
    } catch (err) {
        res.status(502).json({ error: "Discord request failed: " + (err && err.message ? err.message : String(err)) });
    }
}
