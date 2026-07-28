function discordRequest(path, token, method, bodyObj) {
    return new Promise((resolve, reject) => {
        const payload = bodyObj ? JSON.stringify(bodyObj) : null;
        const options = {
            method: method || "GET",
            hostname: "discord.com",
            path: "/api/v10" + path,
            headers: {
                "Authorization": "Bot " + token,
                "Content-Type": "application/json"
            }
        };
        if (payload) options.headers["Content-Length"] = Buffer.byteLength(payload);
        const req = require("https").request(options, (res) => {
            let data = "";
            res.on("data", (c) => { data += c; });
            res.on("end", () => {
                let json = null;
                try { json = JSON.parse(data); } catch (e) { json = data; }
                resolve({ status: res.statusCode, body: json });
            });
        });
        req.on("error", reject);
        if (payload) req.write(payload);
        req.end();
    });
}

async function handleDiscordApi(route, payload, res) {
    const send = (status, obj) => {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Content-Type", "application/json");
        res.status(status).send(JSON.stringify(obj));
    };
    try {
        const token = payload.token || "";
        if (!token) return send(400, { error: "Bot token is required" });

        if (route === "guilds") {
            const r = await discordRequest("/users/@me/guilds", token);
            if (r.status !== 200) return send(r.status, { error: "Discord error", detail: r.body });
            const guilds = Array.isArray(r.body) ? r.body.map((g) => ({ id: g.id, name: g.name, icon: g.icon ? "https://cdn.discordapp.com/icons/" + g.id + "/" + g.icon + ".png" : "" })) : [];
            return send(200, { guilds });
        }

        if (route === "channels") {
            const guildId = payload.guildId || "";
            if (!guildId) return send(400, { error: "guildId is required" });
            const r = await discordRequest("/guilds/" + guildId + "/channels", token);
            if (r.status !== 200) return send(r.status, { error: "Discord error", detail: r.body });
            const channels = Array.isArray(r.body)
                ? r.body
                    .filter((c) => c.type === 0 || c.type === 5 || c.type === 4)
                    .map((c) => ({ id: c.id, name: c.name, type: c.type, parent: c.parent_id || null }))
                : [];
            return send(200, { channels });
        }

        if (route === "create-webhook") {
            const channelId = payload.channelId || "";
            if (!channelId) return send(400, { error: "channelId is required" });
            const r = await discordRequest("/channels/" + channelId + "/webhooks", token, "POST", { name: "PulseCAD" });
            if (r.status < 200 || r.status >= 300) return send(r.status, { error: "Discord error", detail: r.body });
            const wh = r.body;
            const url = wh && wh.url ? wh.url : ("https://discord.com/api/webhooks/" + wh.id + "/" + wh.token);
            return send(200, { webhook: url });
        }

        return send(404, { error: "Unknown discord route: " + route });
    } catch (err) {
        send(500, { error: "Server error: " + err.message });
    }
}

module.exports = async function handler(req, res) {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "content-type");
    if (req.method === "OPTIONS") { res.status(204).end(); return; }
    if (req.method !== "POST") { res.status(405).json({ error: "Method not allowed" }); return; }

    const full = req.url || "";
    const marker = "/api/discord-";
    const idx = full.indexOf(marker);
    const route = idx !== -1 ? full.slice(idx + marker.length).split("?")[0] : "";

    let payload = {};
    try { payload = typeof req.body === "string" ? JSON.parse(req.body) : (req.body || {}); }
    catch (e) { payload = {}; }

    await handleDiscordApi(route, payload, res);
}
