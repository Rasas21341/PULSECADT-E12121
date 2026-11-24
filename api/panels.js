const crypto = require("crypto");

const JOIN_CODE_CHARS = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";

function send(res, status, body) {
    if (status === 204) {
        if (typeof res.status === "function") return res.status(204).end();
        res.writeHead(204);
        return res.end();
    }
    if (typeof res.status === "function" && typeof res.json === "function") {
        return res.status(status).json(body);
    }

    res.writeHead(status, { "Content-Type": "application/json" });
    res.end(JSON.stringify(body));
}

async function readBody(req) {
    if (req.body && typeof req.body === "object") return req.body;
    try {
        let raw = req.body;
        if (typeof raw !== "string") {
            raw = "";
            for await (const chunk of req) raw += chunk;
        }
        return JSON.parse(raw || "{}");
    } catch (err) {
        const error = new Error("Request body must contain valid JSON.");
        error.status = 400;
        throw error;
    }
}

function generateJoinCode() {
    let code = "";
    for (let i = 0; i < 8; i++) {
        code += JOIN_CODE_CHARS.charAt(crypto.randomInt(JOIN_CODE_CHARS.length));
    }
    return code;
}

async function supabaseRequest(path, method, body, prefer) {
    const baseUrl = process.env.SUPABASE_URL.replace(/\/+$/, "");
    const url = new URL(path, baseUrl + "/rest/v1/");
    const headers = {
        apikey: process.env.SUPABASE_SERVICE_ROLE_KEY,
        Authorization: "Bearer " + process.env.SUPABASE_SERVICE_ROLE_KEY,
        "Content-Type": "application/json"
    };
    if (prefer) headers.Prefer = prefer;

    const response = await fetch(url, {
        method,
        headers,
        body: body === undefined ? undefined : JSON.stringify(body)
    });
    const text = await response.text();
    let data = null;
    try {
        data = text ? JSON.parse(text) : null;
    } catch {
        data = text;
    }

    if (!response.ok) {
        const error = new Error(data && data.message ? data.message : "Supabase request failed.");
        error.status = response.status;
        throw error;
    }
    return data;
}

async function verifyDiscordToken(token) {
    const response = await fetch("https://discord.com/api/users/@me", {
        headers: { Authorization: "Bearer " + token }
    });
    if (!response.ok) {
        const error = new Error("Your Discord login expired. Please sign in with Discord again.");
        error.status = 401;
        throw error;
    }

    const user = await response.json();
    if (!user.id || !user.email || user.verified !== true) {
        const error = new Error("A verified Discord email is required to create a panel.");
        error.status = 400;
        throw error;
    }
    return user;
}

function availableKeyQuery(email) {
    const params = new URLSearchParams({
        select: "id",
        used_by: "eq." + email,
        used: "eq.true",
        or: "(used_for_community.is.null,used_for_community.eq.false)",
        order: "created_at.asc"
    });
    return "premium_keys?" + params.toString();
}

async function claimKey(keyId, email) {
    const params = new URLSearchParams({
        id: "eq." + keyId,
        used_by: "eq." + email,
        used: "eq.true",
        or: "(used_for_community.is.null,used_for_community.eq.false)",
        select: "id"
    });
    const rows = await supabaseRequest(
        "premium_keys?" + params.toString(),
        "PATCH",
        { used_for_community: true },
        "return=representation"
    );
    return Array.isArray(rows) && rows.length > 0;
}

async function releaseKey(keyId, email) {
    const params = new URLSearchParams({
        id: "eq." + keyId,
        used_by: "eq." + email,
        used_for_community: "eq.true"
    });
    await supabaseRequest(
        "premium_keys?" + params.toString(),
        "PATCH",
        { used_for_community: false },
        "return=minimal"
    );
}

async function handler(req, res) {
    const origin = (req.headers || {}).origin;
    const allowedOrigins = ["https://www.pulsecad.xyz", "https://pulsecad.xyz", "http://localhost:3000"];
    if (origin && allowedOrigins.includes(origin)) {
        res.setHeader("Access-Control-Allow-Origin", origin);
        res.setHeader("Vary", "Origin");
    }
    res.setHeader("Access-Control-Allow-Methods", "POST, OPTIONS");
    res.setHeader("Access-Control-Allow-Headers", "Content-Type");

    if (req.method === "OPTIONS") {
        return send(res, 204, {});
    }
    if (req.method !== "POST") {
        return send(res, 405, { error: "Method not allowed." });
    }
    if (!process.env.SUPABASE_URL || !process.env.SUPABASE_SERVICE_ROLE_KEY) {
        return send(res, 500, { error: "Panel creation service is not configured." });
    }

    try {
        const payload = await readBody(req);
        const action = payload.action;
        const token = payload.discordToken;
        if (!token || typeof token !== "string") {
            return send(res, 401, { error: "Sign in with Discord to continue." });
        }
        if (action !== "check" && action !== "create") {
            return send(res, 400, { error: "Invalid panel action." });
        }

        const discordUser = await verifyDiscordToken(token);
        const email = discordUser.email;
        const keys = await supabaseRequest(availableKeyQuery(email), "GET");

        if (action === "check") {
            return send(res, 200, {
                available: Array.isArray(keys) && keys.length > 0,
                count: Array.isArray(keys) ? keys.length : 0
            });
        }
        if (!Array.isArray(keys) || keys.length === 0) {
            return send(res, 403, { error: "An assigned, unused key is required to create a panel." });
        }

        const name = typeof payload.name === "string" ? payload.name.trim() : "";
        const description = typeof payload.description === "string" ? payload.description.trim() : "";
        if (!name || name.length > 100 || description.length > 2000) {
            return send(res, 400, { error: "Enter a panel name up to 100 characters and a description up to 2,000 characters." });
        }

        let keyId = null;
        for (const key of keys) {
            if (await claimKey(key.id, email)) {
                keyId = key.id;
                break;
            }
        }
        if (!keyId) {
            return send(res, 409, { error: "That key is already being used. Refresh and try again." });
        }

        try {
            const rows = await supabaseRequest(
                "communities?select=id,name,description,creator_email,join_code,verification_requested,suspended,members_only,banner,partner,created_at",
                "POST",
                [{
                    creator_email: email,
                    name,
                    description,
                    verification_requested: false,
                    join_code: generateJoinCode()
                }],
                "return=representation"
            );
            if (!Array.isArray(rows) || rows.length === 0) {
                throw new Error("The panel was not returned after creation.");
            }
            return send(res, 201, { community: rows[0] });
        } catch (err) {
            try {
                await releaseKey(keyId, email);
            } catch (releaseError) {
                console.error("Failed to release key after panel creation failed:", releaseError);
            }
            throw err;
        }
    } catch (err) {
        console.error("Panel API failed:", err);
        return send(res, err.status || 500, { error: err.message || "Panel request failed." });
    }
}

module.exports = handler;
