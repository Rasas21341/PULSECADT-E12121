const https = require("https");

const SUPABASE_URL = process.env.SUPABASE_URL || "";
const SUPABASE_SERVICE_ROLE_KEY = process.env.SUPABASE_SERVICE_ROLE_KEY || "";

function supabaseRequest(method, supabasePath, body) {
    return new Promise((resolve, reject) => {
        const url = new URL(supabasePath, SUPABASE_URL + "/rest/v1/");
        const payload = body ? JSON.stringify(body) : null;
        const options = {
            method: method,
            hostname: url.hostname,
            path: url.pathname + url.search,
            headers: {
                "apikey": SUPABASE_SERVICE_ROLE_KEY,
                "Authorization": "Bearer " + SUPABASE_SERVICE_ROLE_KEY,
                "Content-Type": "application/json"
            }
        };
        if (payload) options.headers["Content-Length"] = Buffer.byteLength(payload);
        const req = https.request(options, (res) => {
            let data = "";
            res.on("data", (c) => { data += c; });
            res.on("end", () => {
                try { resolve({ status: res.statusCode, body: JSON.parse(data) }); }
                catch (e) { resolve({ status: res.statusCode, body: data }); }
            });
        });
        req.on("error", reject);
        if (payload) req.write(payload);
        req.end();
    });
}

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
        const req = https.request(options, (res) => {
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

module.exports = async (req, res) => {
    if (req.method !== "POST") {
        res.status(405).json({ error: "Method not allowed" });
        return;
    }

    try {
        const payload = req.body || {};
        const communityId = payload.communityId || "";
        const userId = payload.userId || "";
        const action = payload.action || "";

        if (!communityId || !userId || !action) {
            res.status(400).json({ error: "communityId, userId, and action are required" });
            return;
        }

        if (!SUPABASE_SERVICE_ROLE_KEY) {
            res.status(500).json({ error: "Server not configured" });
            return;
        }

        let result;
        if (action === "kick") {
            result = await supabaseRequest("DELETE", `user_communities?user_id=eq.${userId}&community_id=eq.${communityId}`);
        } else if (action === "ban") {
            result = await supabaseRequest("PATCH", `user_communities?user_id=eq.${userId}&community_id=eq.${communityId}`, { banned: true });
        } else {
            res.status(400).json({ error: "Invalid action" });
            return;
        }

        if (result.status < 200 || result.status >= 300) {
            res.status(result.status).json({ error: "Supabase error", detail: result.body });
            return;
        }

        const webhook = payload.webhook || "";
        const username = payload.username || "PulseCAD";
        if (webhook && /^https:\/\/discord(app)?\.com\/api\/webhooks\//.test(webhook)) {
            const actionText = action === "kick" ? "kicked" : "banned";
            const content = `**A user** was **${actionText}** from the community.`;
            const message = { content, username, avatar_url: "" };
            const body = JSON.stringify(message);
            const u = new URL(webhook);
            const options = {
                method: "POST",
                hostname: u.hostname,
                path: u.pathname + u.search,
                headers: { "Content-Type": "application/json", "Content-Length": Buffer.byteLength(body) }
            };
            const wreq = https.request(options, (wres) => {
                let data = "";
                wres.on("data", (c) => { data += c; });
                wres.on("end", () => {
                    res.status(200).json({ ok: true });
                });
            });
            wreq.on("error", () => {
                res.status(200).json({ ok: true });
            });
            wreq.write(body);
            wreq.end();
        } else {
            res.status(200).json({ ok: true });
        }
    } catch (err) {
        res.status(500).json({ error: "Server error: " + err.message });
    }
};
