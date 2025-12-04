// dashboard.js
(async function() {

  // In deployment: UI + API from same domain
  // In development on 63342: API will still call 8080
  const BASE =
      window.location.origin.includes("63342")
          ? "http://localhost:8080"
          : window.location.origin;

  const STATS_URL = BASE + "/api/admin/dashboard/stats";
  const token = localStorage.getItem("adminToken");

  // AUTH GUARD
  if (!token) {
    window.location.href = "/admin-panel/login.html";
    return;
  }

  // wrapper for API calls with token
  function apiFetch(url, opts = {}) {
    opts.headers = Object.assign({
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer " + token
    }, opts.headers || {});
    return fetch(url, opts).then(r =>
        r.json().then(body => ({ ok: r.ok, status: r.status, body }))
    );
  }

  // decode JWT token for admin name
  function decodePayload(jwt) {
    try {
      const parts = jwt.split('.');
      if (parts.length !== 3) return null;
      return JSON.parse(atob(parts[1].replace(/-/g, '+').replace(/_/g, '/')));
    } catch (e) {
      return null;
    }
  }

  const payload = decodePayload(token);
  if (payload && payload.sub) {
    document.getElementById("adminName").innerText = "Admin ID: " + payload.sub;
  }

  // LOGOUT
  document.getElementById("logoutBtn").addEventListener("click", () => {
      localStorage.removeItem("adminToken");

      if (window.location.origin.includes("63342")) {
          // development mode
          window.location.href = "/salon-management-system/static/admin-panel/login.html";
      } else {
          // production / spring boot hosted
          window.location.href = "/admin-panel/login.html";
      }
  });

  // FETCH & RENDER STATS
  try {
    const res = await apiFetch(STATS_URL);

    if (!res.ok) {
      console.error("Failed to fetch stats", res);

      if (res.status === 401 || res.status === 403) {
        localStorage.removeItem("adminToken");
        window.location.href = "/admin-panel/login.html";
      }
      return;
    }

    const data = res.body.data ?? res.body;

    const totalUsers = data.totalUsers ?? 0;
    const totalOwners = data.totalOwners ?? 0;
    const totalCustomers = data.totalCustomers ?? 0;
    const totalSalons = data.totalSalons ?? 0;
    const pendingApprovals = data.pendingApprovals ?? 0;
    const latest = data.latestSalons ?? [];

    document.getElementById("totalUsers").innerText = totalUsers;
    document.getElementById("totalOwners").innerText = totalOwners;
    const customersEl = document.getElementById("totalCustomers");
    if (customersEl) {
      customersEl.innerText = totalCustomers;
    }
    document.getElementById("totalSalons").innerText = totalSalons;
    document.getElementById("pendingApprovals").innerText = pendingApprovals;

    // CHART
    const ctx = document.getElementById("overviewChart").getContext("2d");
    new Chart(ctx, {
      type: "doughnut",
      data: {
        labels: ["Users", "Owners", "Salons", "Pending"],
        datasets: [{
          data: [totalUsers, totalOwners, totalSalons, pendingApprovals]
        }]
      },
      options: {
        responsive: true,
        plugins: { legend: { position: "bottom" } }
      }
    });

    // LATEST SALONS
    const listEl = document.getElementById("latestSalons");
    listEl.innerHTML = "";

    if (Array.isArray(latest) && latest.length > 0) {
      latest.slice(0, 6).forEach(s => {
        const li = document.createElement("li");

        const name = document.createElement("div");
        name.className = "salon-name";
        name.innerText = s.name || s.salonName || ("Salon #" + s.id);

        const meta = document.createElement("div");
        meta.className = "salon-meta";
        meta.innerText = (s.city ? s.city + " • " : "") + (s.ownerName ?? "");

        li.appendChild(name);
        li.appendChild(meta);
        listEl.appendChild(li);
      });
    } else {
      listEl.innerHTML = "<li>No recent Salon requests available</li>";
    }

  } catch (err) {
    console.error("Error loading dashboard", err);
  }
})();
