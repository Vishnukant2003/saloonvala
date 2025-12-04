document.getElementById("loginForm").addEventListener("submit", async function(e) {
    e.preventDefault();

    const username = document.getElementById("username").value;
    const password = document.getElementById("password").value;

    const errorBox = document.getElementById("error-box");
    errorBox.innerHTML = "";

    const bodyData = {
        mobile: username,
        password: password
    };

    try {
       const API_BASE =
           window.location.origin.includes("63342")
               ? "http://localhost:8080"
               : window.location.origin;

       const res = await fetch(`${API_BASE}/api/auth/login`, {
           method: "POST",
           headers: { "Content-Type": "application/json" },
           body: JSON.stringify(bodyData)
       });

        const data = await res.json();

        if (res.status !== 200) {
            errorBox.innerHTML = data.message || "Invalid Credentials";
            return;
        }

        // Only admin can login
        if (data.data.role !== "ADMIN") {
            errorBox.innerHTML = "Access denied: Admin only";
            return;
        }

        // Save token
        localStorage.setItem("adminToken", data.data.token);

        // Redirect to dashboard
        window.location.href = "../admin-panel/dashboard.html";

    } catch (error) {
        errorBox.innerHTML = "Server error";
    }
});
