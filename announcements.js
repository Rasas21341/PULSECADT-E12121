(function () {
    var SUPABASE_URL = "https://zwdogalwbczdtvxvhrfd.supabase.co";
    var SUPABASE_ANON_KEY = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp3ZG9nYWx3YmN6ZHR2eHZocmZkIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODM2NTA2MjQsImV4cCI6MjA5OTIyNjYyNH0.baPVVTtW0d3FDC2pTd1P3d5aoIc2FZkaD-6bBvDPFWw";
    var DISPLAY_MS = 10000;

    var bannerEl = null;
    var hideTimer = null;
    var cleanupTimer = null;
    var lastShownId = null;

    function ensureBanner() {
        if (bannerEl && document.body.contains(bannerEl)) return bannerEl;
        bannerEl = document.createElement("div");
        bannerEl.id = "globalAnnouncementBanner";
        bannerEl.style.cssText = [
            "position:fixed",
            "top:16px",
            "left:50%",
            "transform:translateX(-50%) translateY(-24px)",
            "display:none",
            "align-items:center",
            "gap:10px",
            "max-width:min(90vw, 640px)",
            "padding:12px 18px",
            "border-radius:12px",
            "background:#0f172a",
            "color:#ffffff",
            "font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,Oxygen,Ubuntu,Cantarell,sans-serif",
            "font-size:14px",
            "line-height:1.4",
            "box-shadow:0 12px 32px rgba(15,23,42,0.35)",
            "z-index:2147483647",
            "opacity:0",
            "transition:opacity 0.25s ease, transform 0.25s ease",
            "pointer-events:none"
        ].join(";");
        document.body.appendChild(bannerEl);
        return bannerEl;
    }

    function hide() {
        if (!bannerEl) return;
        if (hideTimer) { clearTimeout(hideTimer); hideTimer = null; }
        bannerEl.style.opacity = "0";
        bannerEl.style.transform = "translateX(-50%) translateY(-24px)";
        if (cleanupTimer) clearTimeout(cleanupTimer);
        cleanupTimer = setTimeout(function () {
            if (bannerEl) bannerEl.style.display = "none";
        }, 260);
    }

    function show(id, message) {
        if (!message) return;
        if (id != null && String(id) === String(lastShownId)) return;
        lastShownId = id;

        var el = ensureBanner();
        el.innerHTML = "";

        var label = document.createElement("span");
        label.textContent = "Announcement";
        label.style.cssText = [
            "flex:0 0 auto",
            "padding:3px 8px",
            "border-radius:999px",
            "background:#2563eb",
            "color:#ffffff",
            "font-size:10px",
            "font-weight:700",
            "letter-spacing:0.4px",
            "text-transform:uppercase"
        ].join(";");

        var text = document.createElement("span");
        text.textContent = message;
        text.style.cssText = "flex:1 1 auto; font-weight:600; word-break:break-word;";

        el.appendChild(label);
        el.appendChild(text);

        el.style.display = "flex";
        void el.offsetWidth;
        el.style.opacity = "1";
        el.style.transform = "translateX(-50%) translateY(0)";

        if (hideTimer) clearTimeout(hideTimer);
        hideTimer = setTimeout(hide, DISPLAY_MS);
    }

    function getClient() {
        try {
            if (typeof localSupabase !== "undefined" && localSupabase) return localSupabase;
        } catch (err) { /* page has no shared client */ }
        if (typeof window.supabase === "undefined") return null;
        try {
            return window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
        } catch (err) {
            return null;
        }
    }

    function init() {
        var client = getClient();
        if (!client) return;

        client.auth.getSession().then(function (res) {
            var session = res && res.data ? res.data.session : null;
            if (!session) return;

            client
                .channel("global-announcements")
                .on("postgres_changes", { event: "INSERT", schema: "public", table: "announcements" }, function (payload) {
                    var row = payload && payload.new ? payload.new : null;
                    if (row) show(row.id, row.message);
                })
                .subscribe();

            client
                .from("announcements")
                .select("id, message, created_at")
                .order("created_at", { ascending: false })
                .limit(1)
                .then(function (result) {
                    if (result.error || !Array.isArray(result.data) || result.data.length === 0) return;
                    var latest = result.data[0];
                    var created = new Date(latest.created_at).getTime();
                    if (isNaN(created)) return;
                    var age = Date.now() - created;
                    if (age >= 0 && age < DISPLAY_MS) show(latest.id, latest.message);
                })
                .catch(function () {});
        }).catch(function () {});
    }

    if (document.body) {
        init();
    } else {
        document.addEventListener("DOMContentLoaded", init);
    }
})();
