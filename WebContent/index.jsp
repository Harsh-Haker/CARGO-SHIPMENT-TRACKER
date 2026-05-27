<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%--
    index.jsp — Home Page / Search Dashboard
    MVC Layer: View

    Responsibilities:
    - Display shipment ID search form (POST → /trackShipment)
    - Auto-fill customer name from Cookie
    - Display recent searches from Session (via sidebar)
    - Show feature highlights
--%>
<%
    /* ======= READ COOKIE: customer name auto-fill ======= */
    String savedCustomerName = "";
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
        for (Cookie c : cookies) {
            if ("customerName".equals(c.getName())) {
                savedCustomerName = c.getValue();
                break;
            }
        }
    }

    /* ======= READ SESSION: recent searches ======= */
    @SuppressWarnings("unchecked")
    List<String> recentSearches = (List<String>) session.getAttribute("recentSearches");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cargo Shipment Tracker — Real-Time Logistics Dashboard</title>
    <meta name="description" content="Track your cargo shipments in real-time. Get live updates on delivery status, location, and estimated arrival times with CargoTrack Pro.">

    <!-- Bootstrap 5 -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" rel="stylesheet">
    <!-- Custom CSS -->
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<!-- ======================== NAVBAR ======================== -->
<nav class="navbar navbar-expand-lg">
    <div class="container">
        <a class="navbar-brand" href="index.jsp" id="nav-brand-home">
            <span class="brand-icon">📦</span>
            CargoTrack Pro
        </a>
        <button class="navbar-toggler" type="button"
                data-bs-toggle="collapse" data-bs-target="#navMenu"
                aria-controls="navMenu" aria-expanded="false"
                aria-label="Toggle navigation">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navMenu">
            <ul class="navbar-nav ms-auto gap-1">
                <li class="nav-item">
                    <a class="nav-link active" href="index.jsp" id="nav-home">
                        <i class="bi bi-house-door"></i> Home
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#features" id="nav-features">
                        <i class="bi bi-grid"></i> Features
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="#how-it-works" id="nav-how">
                        <i class="bi bi-info-circle"></i> How It Works
                    </a>
                </li>
            </ul>
            <% if (!savedCustomerName.isEmpty()) { %>
            <div class="ms-3">
                <span class="cookie-notice py-2" style="margin:0; font-size:0.8rem;">
                    <i class="bi bi-person-check cookie-notice-icon"></i>
                    Welcome back, <strong>&nbsp;<%= savedCustomerName %></strong>!
                </span>
            </div>
            <% } %>
        </div>
    </div>
</nav>

<!-- ======================== HERO SECTION ======================== -->
<section class="hero-section">
    <div class="container">
        <div class="row align-items-center g-5">

            <!-- LEFT: Hero Text + Search Form -->
            <div class="col-lg-6">
                <div class="hero-badge">
                    <span class="dot"></span>
                    Live Tracking System
                </div>
                <h1 class="hero-title">
                    Track Your Cargo<br>In Real-Time
                </h1>
                <p class="hero-subtitle">
                    Get instant visibility into your shipment's journey —
                    from warehouse pickup to doorstep delivery.
                    Powered by live database updates.
                </p>

                <!-- Shipment Search Form (POST) -->
                <div class="search-card">
                    <div class="search-card-title">
                        <i class="bi bi-search" style="color: var(--primary);"></i>
                        Track a Shipment
                    </div>

                    <%-- Cookie notice if name is remembered --%>
                    <% if (!savedCustomerName.isEmpty()) { %>
                    <div class="cookie-notice" id="cookie-notice">
                        <i class="bi bi-cookie cookie-notice-icon"></i>
                        <span>Your name was remembered from your last visit via cookie.</span>
                    </div>
                    <% } %>

                    <form action="trackShipment" method="POST" id="trackingForm" novalidate>

                        <!-- Shipment ID field -->
                        <div class="mb-3">
                            <label for="shipmentId" class="form-label">
                                <i class="bi bi-upc-scan"></i>&nbsp; Shipment ID *
                            </label>
                            <input type="text"
                                   class="form-control"
                                   id="shipmentId"
                                   name="shipmentId"
                                   placeholder="e.g.  CST001, CST002 …"
                                   autocomplete="off"
                                   required
                                   maxlength="20">
                            <div class="invalid-feedback" id="shipmentIdError" style="color: var(--danger); font-size:0.8rem; margin-top:0.3rem; display:none;">
                                <i class="bi bi-exclamation-circle"></i> Please enter a Shipment ID.
                            </div>
                        </div>

                        <!-- Customer name field (auto-filled from cookie) -->
                        <div class="mb-3">
                            <label for="customerName" class="form-label">
                                <i class="bi bi-person"></i>&nbsp; Your Name
                                <span style="color:var(--text-muted); font-size:0.75rem;">(optional — saved in cookie)</span>
                            </label>
                            <input type="text"
                                   class="form-control"
                                   id="customerName"
                                   name="customerName"
                                   placeholder="Enter your name"
                                   value="<%= savedCustomerName %>"
                                   maxlength="80">
                        </div>

                        <!-- Submit button -->
                        <button type="submit" class="btn-primary-custom" id="trackBtn">
                            <i class="bi bi-search"></i>
                            Track Shipment
                        </button>
                    </form>

                    <div class="divider"></div>
                    <p style="font-size:0.78rem; color:var(--text-muted); text-align:center; margin:0;">
                        <i class="bi bi-info-circle"></i>&nbsp;
                        Try: <strong style="color:var(--primary);">CST001</strong> &bull;
                             <strong style="color:var(--primary);">CST002</strong> &bull;
                             <strong style="color:var(--primary);">CST003</strong>
                    </p>
                </div>
            </div>

            <!-- RIGHT: Recent Searches + Info Panel -->
            <div class="col-lg-6">
                <!-- Recent Searches (Session) -->
                <div class="section-card mb-3">
                    <div class="section-card-header">
                        <div class="section-card-icon">
                            <i class="bi bi-clock-history" style="color:var(--primary)"></i>
                        </div>
                        <div>
                            <h2 class="section-card-title">Recent Searches</h2>
                            <p style="font-size:0.75rem; color:var(--text-muted); margin:0;">Session-stored history</p>
                        </div>
                    </div>

                    <% if (recentSearches != null && !recentSearches.isEmpty()) { %>
                    <ul class="recent-search-list">
                        <% for (String sid : recentSearches) { %>
                        <li>
                            <a href="trackShipment?shipmentId=<%= sid %>"
                               class="recent-search-item" id="recent-<%= sid.toLowerCase() %>">
                                <div class="recent-search-icon">
                                    <i class="bi bi-box-seam" style="color:var(--primary)"></i>
                                </div>
                                <span class="recent-search-id"><%= sid %></span>
                                <i class="bi bi-arrow-right ms-auto" style="color:var(--text-muted); font-size:0.8rem;"></i>
                            </a>
                        </li>
                        <% } %>
                    </ul>
                    <% } else { %>
                    <div class="recent-search-empty">
                        <i class="bi bi-clock" style="font-size:2rem; margin-bottom:0.5rem; display:block; opacity:0.4;"></i>
                        No recent searches yet.<br>Track a shipment to get started!
                    </div>
                    <% } %>
                </div>

                <!-- Quick Info Card -->
                <div class="section-card">
                    <div class="section-card-header">
                        <div class="section-card-icon">
                            <i class="bi bi-shield-check" style="color:var(--success)"></i>
                        </div>
                        <h3 class="section-card-title">How It Works</h3>
                    </div>
                    <div style="display:flex; flex-direction:column; gap:0.75rem;">
                        <div style="display:flex; align-items:center; gap:0.75rem;">
                            <div style="width:28px; height:28px; background:rgba(0,212,255,0.12); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:0.85rem; flex-shrink:0;">1</div>
                            <span style="font-size:0.875rem; color:var(--text-secondary);">Enter your Shipment ID in the search box</span>
                        </div>
                        <div style="display:flex; align-items:center; gap:0.75rem;">
                            <div style="width:28px; height:28px; background:rgba(0,212,255,0.12); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:0.85rem; flex-shrink:0;">2</div>
                            <span style="font-size:0.875rem; color:var(--text-secondary);">Our system fetches live data from the database</span>
                        </div>
                        <div style="display:flex; align-items:center; gap:0.75rem;">
                            <div style="width:28px; height:28px; background:rgba(0,212,255,0.12); border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:0.85rem; flex-shrink:0;">3</div>
                            <span style="font-size:0.875rem; color:var(--text-secondary);">View your full delivery timeline instantly</span>
                        </div>
                    </div>
                </div>
            </div>

        </div><!-- /.row -->
    </div><!-- /.container -->
</section>

<!-- ======================== STATS STRIP ======================== -->
<div class="stats-strip" id="how-it-works">
    <div class="container">
        <div class="row">
            <div class="col-6 col-md-3 stat-item">
                <div class="stat-number">10K+</div>
                <div class="stat-label">Shipments Tracked</div>
            </div>
            <div class="col-6 col-md-3 stat-item">
                <div class="stat-number">98%</div>
                <div class="stat-label">On-Time Delivery</div>
            </div>
            <div class="col-6 col-md-3 stat-item">
                <div class="stat-number">150+</div>
                <div class="stat-label">Cities Covered</div>
            </div>
            <div class="col-6 col-md-3 stat-item">
                <div class="stat-number">24/7</div>
                <div class="stat-label">Live Tracking</div>
            </div>
        </div>
    </div>
</div>

<!-- ======================== FEATURES SECTION ======================== -->
<section class="py-5" id="features">
    <div class="container">
        <div class="text-center mb-4">
            <p style="font-size:0.8rem; letter-spacing:2px; text-transform:uppercase; color:var(--primary); margin-bottom:0.5rem;">WHY CHOOSE US</p>
            <h2 style="font-size:1.75rem; font-weight:700; color:var(--text-primary);">Everything You Need in One Place</h2>
        </div>

        <div class="feature-grid">
            <div class="feature-card">
                <div class="feature-card-icon blue">📍</div>
                <div class="feature-card-title">Real-Time Location</div>
                <div class="feature-card-desc">Know exactly where your package is at every stage of delivery.</div>
            </div>
            <div class="feature-card">
                <div class="feature-card-icon green">🕐</div>
                <div class="feature-card-title">Timeline Tracking</div>
                <div class="feature-card-desc">Visual 6-stage delivery timeline from Order Placed to Delivered.</div>
            </div>
            <div class="feature-card">
                <div class="feature-card-icon orange">🔒</div>
                <div class="feature-card-title">Session History</div>
                <div class="feature-card-desc">Your last 3 searches are stored in session for quick access.</div>
            </div>
            <div class="feature-card">
                <div class="feature-card-icon purple">🍪</div>
                <div class="feature-card-title">Cookie Persistence</div>
                <div class="feature-card-desc">Your name is remembered across visits using browser cookies.</div>
            </div>
        </div>
    </div>
</section>

<!-- ======================== FOOTER ======================== -->
<footer class="footer">
    <div class="container">
        <p class="footer-text">
            &copy; 2025 <strong style="color:var(--primary);">CargoTrack Pro</strong> &mdash;
            Built with Java Servlets, JSP, JDBC &amp; MySQL &bull;
            MVC Architecture Demo
        </p>
    </div>
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- Form Validation Script -->
<script>
(function () {
    'use strict';

    const form    = document.getElementById('trackingForm');
    const input   = document.getElementById('shipmentId');
    const errDiv  = document.getElementById('shipmentIdError');
    const trackBtn = document.getElementById('trackBtn');

    form.addEventListener('submit', function (e) {
        const val = input.value.trim();
        if (!val) {
            e.preventDefault();
            errDiv.style.display = 'block';
            input.style.borderColor = 'var(--danger)';
            input.focus();
            return;
        }
        errDiv.style.display = 'none';
        input.style.borderColor = '';

        // Show loading state
        trackBtn.innerHTML = '<span class="spinner"></span>&nbsp; Tracking…';
        trackBtn.disabled = true;
    });

    input.addEventListener('input', function () {
        errDiv.style.display = 'none';
        input.style.borderColor = '';
    });

    // Auto-uppercase shipment ID
    input.addEventListener('blur', function () {
        this.value = this.value.toUpperCase();
    });
})();
</script>

</body>
</html>
