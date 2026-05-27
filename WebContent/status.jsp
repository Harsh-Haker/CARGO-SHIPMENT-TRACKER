<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="model.Shipment, java.util.List" %>
<%--
    status.jsp — Shipment Tracking Result Page
    MVC Layer: View

    Displays:
    - Full shipment details (set by TrackShipmentServlet)
    - Visual 6-stage delivery timeline (with active stage highlighted)
    - Recent search history from session
    - GET-method re-track links

    Uses:
    - JSP Scriptlets      (<% ... %>)
    - JSP Expressions     (<%= ... %>)
    - EL Expressions      (${...})
    - JSP Declarations    (<%! ... %>)
    - request.getAttribute()
    - session.getAttribute()
--%>
<%
    /* ======= Retrieve model objects set by TrackShipmentServlet ======= */
    Shipment shipment = (Shipment) request.getAttribute("shipment");
    @SuppressWarnings("unchecked")
    List<String> recentSearches = (List<String>) request.getAttribute("recentSearches");
    String cookieName = (String) request.getAttribute("customerNameFromCookie");

    /* Guard: if no shipment, redirect to home */
    if (shipment == null) {
        response.sendRedirect(request.getContextPath() + "/index.jsp");
        return;
    }

    int currentStage = shipment.getStatusStage();
%>
<%!
    /**
     * JSP Declaration: Returns Bootstrap-friendly CSS class for a status string.
     * Used in the status badge display.
     */
    private String getStatusClass(String status) {
        if (status == null) return "order-placed";
        switch (status.toLowerCase().trim()) {
            case "delivered":        return "delivered";
            case "in transit":       return "in-transit";
            case "out for delivery": return "out-delivery";
            case "packed":           return "packed";
            case "arrived at hub":   return "arrived-hub";
            default:                 return "order-placed";
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Tracking: <%= shipment.getShipmentId() %> — CargoTrack Pro</title>
    <meta name="description" content="Track shipment <%= shipment.getShipmentId() %> for <%= shipment.getCustomerName() %>. Current status: <%= shipment.getShipmentStatus() %>.">

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
                    <a class="nav-link" href="index.jsp" id="nav-home">
                        <i class="bi bi-house-door"></i> Home
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link" href="index.jsp#features" id="nav-features">
                        <i class="bi bi-grid"></i> Features
                    </a>
                </li>
            </ul>
            <% if (cookieName != null && !cookieName.isEmpty()) { %>
            <div class="ms-3">
                <span class="cookie-notice py-2" style="margin:0; font-size:0.8rem;">
                    <i class="bi bi-person-check cookie-notice-icon"></i>
                    &nbsp;<strong><%= cookieName %></strong>
                </span>
            </div>
            <% } %>
        </div>
    </div>
</nav>

<!-- ======================== PAGE HEADER ======================== -->
<div style="background: var(--bg-surface); border-bottom:1px solid var(--border); padding:1.5rem 0;">
    <div class="container">
        <div class="d-flex align-items-center gap-3 flex-wrap">
            <a href="index.jsp" class="btn-secondary-custom" id="btn-back-home">
                <i class="bi bi-arrow-left"></i> Back
            </a>
            <div>
                <p style="font-size:0.75rem; color:var(--text-muted); margin:0; text-transform:uppercase; letter-spacing:1px;">
                    Shipment Details
                </p>
                <h1 style="font-size:1.25rem; font-weight:700; color:var(--text-primary); margin:0;">
                    Tracking: <span style="color:var(--primary)"><%= shipment.getShipmentId() %></span>
                </h1>
            </div>
            <div class="ms-auto">
                <span class="status-badge <%= getStatusClass(shipment.getShipmentStatus()) %>">
                    <i class="bi bi-circle-fill" style="font-size:0.5rem;"></i>
                    <%= shipment.getShipmentStatus() %>
                </span>
            </div>
        </div>
    </div>
</div>

<!-- ======================== MAIN CONTENT ======================== -->
<div style="padding: 2rem 0 4rem;">
    <div class="container">
        <div class="row g-4">

            <!-- ==================== LEFT COLUMN ==================== -->
            <div class="col-lg-8">

                <!-- ---- Shipment Info Card ---- -->
                <div class="shipment-info-card mb-4 fade-in" id="shipment-card">
                    <div class="shipment-id-badge">
                        <i class="bi bi-upc-scan"></i>
                        <%= shipment.getShipmentId() %>
                    </div>

                    <!-- Customer name (EL Expression demo) -->
                    <h2 style="font-size:1.3rem; font-weight:700; color:var(--text-primary); margin-bottom:0.25rem;">
                        ${shipment.customerName}
                    </h2>
                    <p style="font-size:0.85rem; color:var(--text-muted); margin-bottom:1.25rem;">
                        <i class="bi bi-geo-alt"></i>
                        ${shipment.originCity} &nbsp;&#8594;&nbsp; ${shipment.destinationCity}
                    </p>

                    <!-- Description -->
                    <% if (shipment.getDescription() != null && !shipment.getDescription().isEmpty()) { %>
                    <p style="font-size:0.875rem; color:var(--text-secondary); background:var(--bg-glass); border:1px solid var(--border); padding:0.75rem 1rem; border-radius:var(--radius-md); margin-bottom:1.25rem;">
                        <i class="bi bi-info-circle" style="color:var(--primary);"></i>
                        &nbsp;<%= shipment.getDescription() %>
                    </p>
                    <% } %>

                    <!-- Info Grid: JSP Expressions + EL Expressions -->
                    <div class="info-grid">

                        <div class="info-item">
                            <div class="info-item-label"><i class="bi bi-pin-map"></i> Current Location</div>
                            <div class="info-item-value" style="color:var(--primary);">
                                ${shipment.currentLocation}
                            </div>
                        </div>

                        <div class="info-item">
                            <div class="info-item-label"><i class="bi bi-truck"></i> Status</div>
                            <div class="info-item-value">
                                <span class="status-badge <%= getStatusClass(shipment.getShipmentStatus()) %>">
                                    <%= shipment.getShipmentStatus() %>
                                </span>
                            </div>
                        </div>

                        <div class="info-item">
                            <div class="info-item-label"><i class="bi bi-calendar-check"></i> Expected Delivery</div>
                            <div class="info-item-value" style="color:var(--success);">
                                <%
                                    // JSP Scriptlet: format date
                                    if (shipment.getExpectedDelivery() != null) {
                                        java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat("dd MMM yyyy");
                                        out.print(sdf.format(shipment.getExpectedDelivery()));
                                    } else {
                                        out.print("—");
                                    }
                                %>
                            </div>
                        </div>

                        <div class="info-item">
                            <div class="info-item-label"><i class="bi bi-clock"></i> Last Updated</div>
                            <div class="info-item-value">
                                <%
                                    // JSP Scriptlet: format timestamp
                                    if (shipment.getLastUpdated() != null) {
                                        java.text.SimpleDateFormat tdf = new java.text.SimpleDateFormat("dd MMM yyyy, hh:mm a");
                                        out.print(tdf.format(shipment.getLastUpdated()));
                                    } else {
                                        out.print("—");
                                    }
                                %>
                            </div>
                        </div>

                        <div class="info-item">
                            <div class="info-item-label"><i class="bi bi-geo"></i> Origin</div>
                            <div class="info-item-value">${shipment.originCity}</div>
                        </div>

                        <div class="info-item">
                            <div class="info-item-label"><i class="bi bi-geo-fill"></i> Destination</div>
                            <div class="info-item-value">${shipment.destinationCity}</div>
                        </div>

                    </div><!-- /.info-grid -->
                </div>

                <!-- ---- Timeline Card ---- -->
                <div class="section-card fade-in" id="timeline-card">
                    <div class="section-card-header">
                        <div class="section-card-icon">
                            <i class="bi bi-signpost-2" style="color:var(--primary)"></i>
                        </div>
                        <div>
                            <h2 class="section-card-title">Delivery Timeline</h2>
                            <p style="font-size:0.75rem; color:var(--text-muted); margin:0;">
                                Stage <%= currentStage %> of 6
                                &bull; Current: <strong style="color:var(--primary);"><%= shipment.getShipmentStatus() %></strong>
                            </p>
                        </div>
                    </div>

                    <%-- ============================================================
                         TIMELINE: 6 stages
                         Logic:
                           stage < currentStage  → completed  (green check)
                           stage == currentStage → active     (blue, pulsing)
                           stage > currentStage  → pending    (grey)
                         ============================================================ --%>

                    <%
                        // Define the timeline stages as arrays
                        String[] stageNames = {
                            "Order Placed",
                            "Packed",
                            "In Transit",
                            "Arrived at Hub",
                            "Out for Delivery",
                            "Delivered"
                        };
                        String[] stageIcons = { "📋", "📦", "🚚", "🏭", "🛵", "✅" };
                        String[] stageDescriptions = {
                            "Your order has been received and confirmed",
                            "Items securely packed and ready for dispatch",
                            "Package is on the way to destination city",
                            "Arrived at the nearest distribution hub",
                            "Out for final delivery to your address",
                            "Package successfully delivered — Enjoy!"
                        };
                    %>

                    <div class="timeline-container">
                        <div class="timeline-track">
                            <% for (int i = 0; i < stageNames.length; i++) {
                                int stageNum = i + 1;
                                boolean isCompleted = stageNum < currentStage;
                                boolean isActive    = stageNum == currentStage;
                                boolean isPending   = stageNum > currentStage;

                                String dotClass     = isCompleted ? "completed" : (isActive ? "active" : "pending");
                                String textClass    = dotClass;
                                String lineClass    = (stageNum < currentStage) ? "completed" : "pending";
                            %>
                            <div class="timeline-item" id="stage-<%= stageNum %>">
                                <!-- Connector column -->
                                <div class="timeline-connector">
                                    <div class="timeline-dot <%= dotClass %>">
                                        <% if (isCompleted) { %>
                                            <i class="bi bi-check-lg" style="color:#fff;"></i>
                                        <% } else { %>
                                            <%= stageIcons[i] %>
                                        <% } %>
                                    </div>
                                    <% if (i < stageNames.length - 1) { %>
                                    <div class="timeline-line <%= lineClass %>" style="min-height:30px;"></div>
                                    <% } %>
                                </div>

                                <!-- Content column -->
                                <div class="timeline-content">
                                    <div class="timeline-stage-name <%= textClass %>">
                                        <%= stageNames[i] %>
                                        <% if (isActive) { %>
                                        &nbsp;<span style="font-size:0.72rem; background:rgba(0,212,255,0.12); color:var(--primary); padding:0.15rem 0.5rem; border-radius:100px; font-weight:600;">CURRENT</span>
                                        <% } %>
                                    </div>
                                    <div class="timeline-stage-desc"><%= stageDescriptions[i] %></div>
                                </div>
                            </div>
                            <% } /* end for loop */ %>
                        </div>
                    </div>
                </div><!-- /timeline card -->

            </div><!-- /col-lg-8 -->

            <!-- ==================== RIGHT COLUMN ==================== -->
            <div class="col-lg-4">

                <!-- Quick Track Another (GET method demo) -->
                <div class="section-card mb-3 slide-in-left">
                    <div class="section-card-header">
                        <div class="section-card-icon">
                            <i class="bi bi-search" style="color:var(--primary)"></i>
                        </div>
                        <h3 class="section-card-title">Track Another</h3>
                    </div>
                    <%-- This form uses HTTP GET --%>
                    <form action="trackShipment" method="GET" id="quickTrackForm">
                        <div class="mb-3">
                            <label for="quickShipmentId" class="form-label">Shipment ID</label>
                            <input type="text"
                                   class="form-control"
                                   id="quickShipmentId"
                                   name="shipmentId"
                                   placeholder="e.g. CST002"
                                   autocomplete="off"
                                   maxlength="20">
                        </div>
                        <button type="submit" class="btn-primary-custom" id="btn-quick-track" style="font-size:0.9rem; padding:0.65rem 1rem;">
                            <i class="bi bi-search"></i> Quick Track (GET)
                        </button>
                    </form>
                </div>

                <!-- Recent Searches (Session) -->
                <div class="section-card mb-3 slide-in-left">
                    <div class="section-card-header">
                        <div class="section-card-icon">
                            <i class="bi bi-clock-history" style="color:var(--warning)"></i>
                        </div>
                        <div>
                            <h3 class="section-card-title">Search History</h3>
                            <p style="font-size:0.73rem; color:var(--text-muted); margin:0;">Stored in HTTP Session</p>
                        </div>
                    </div>

                    <% if (recentSearches != null && !recentSearches.isEmpty()) { %>
                    <ul class="recent-search-list">
                        <% for (String sid : recentSearches) {
                            boolean isCurrent = sid.equals(shipment.getShipmentId());
                        %>
                        <li>
                            <a href="trackShipment?shipmentId=<%= sid %>"
                               class="recent-search-item"
                               id="history-<%= sid.toLowerCase() %>"
                               style="<%= isCurrent ? "border-color:var(--primary); background:rgba(0,212,255,0.04);" : "" %>">
                                <div class="recent-search-icon">
                                    <i class="bi bi-<%= isCurrent ? "box-seam-fill" : "box-seam" %>"
                                       style="color:var(--primary)"></i>
                                </div>
                                <span class="recent-search-id"><%= sid %></span>
                                <% if (isCurrent) { %>
                                <span style="font-size:0.68rem; color:var(--primary); margin-left:auto;">NOW</span>
                                <% } else { %>
                                <i class="bi bi-arrow-right ms-auto" style="color:var(--text-muted); font-size:0.8rem;"></i>
                                <% } %>
                            </a>
                        </li>
                        <% } %>
                    </ul>
                    <% } else { %>
                    <div class="recent-search-empty">No history yet.</div>
                    <% } %>
                </div>

                <!-- Cookie Info Card -->
                <div class="section-card slide-in-left">
                    <div class="section-card-header">
                        <div class="section-card-icon">
                            <i class="bi bi-cookie" style="color:var(--warning)"></i>
                        </div>
                        <div>
                            <h3 class="section-card-title">Cookie Info</h3>
                            <p style="font-size:0.73rem; color:var(--text-muted); margin:0;">Persistent across visits</p>
                        </div>
                    </div>
                    <% if (cookieName != null && !cookieName.isEmpty()) { %>
                    <div style="background:var(--bg-glass); border:1px solid rgba(0,212,255,0.15); border-radius:var(--radius-md); padding:1rem;">
                        <div style="font-size:0.75rem; color:var(--text-muted); margin-bottom:0.3rem;">Saved Name (7 days)</div>
                        <div style="font-size:1rem; font-weight:600; color:var(--primary);">
                            <i class="bi bi-person-circle"></i> &nbsp;<%= cookieName %>
                        </div>
                    </div>
                    <% } else { %>
                    <div class="recent-search-empty" style="font-size:0.8rem;">
                        <i class="bi bi-cookie" style="font-size:1.5rem; opacity:0.3; display:block; margin-bottom:0.4rem;"></i>
                        No name cookie set.<br>Enter your name on the home page.
                    </div>
                    <% } %>
                </div>

            </div><!-- /col-lg-4 -->
        </div><!-- /.row -->
    </div><!-- /.container -->
</div>

<!-- ======================== FOOTER ======================== -->
<footer class="footer">
    <div class="container">
        <p class="footer-text">
            &copy; 2025 <strong style="color:var(--primary);">CargoTrack Pro</strong> &mdash;
            Java Servlets &bull; JSP &bull; JDBC &bull; MySQL &bull; MVC Architecture
        </p>
    </div>
</footer>

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
<script>
    // Auto-uppercase quick track input
    document.getElementById('quickShipmentId').addEventListener('blur', function () {
        this.value = this.value.toUpperCase();
    });
</script>
</body>
</html>
