<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isErrorPage="true" %>
<%--
    error.jsp — Unified Error Display Page
    MVC Layer: View

    Handles:
    - Validation errors (empty input)
    - Database errors (JDBC / SQL failures)
    - Not-found errors (unknown shipment ID)
    - HTTP errors (404, 500 via web.xml error-page config)

    Attributes read from request:
    - errorMessage  : User-friendly description (HTML allowed)
    - errorType     : "validation" | "database" | "notfound" | null
    - searchedId    : The ID that was searched (for not-found)
    - exceptionDetail : Technical detail (from exception)

    Also handles errors routed via Tomcat's error-page mechanism
    (uses javax.servlet.error.* attributes).
--%>
<%
    /* ======= Read custom error attributes (from servlet forward) ======= */
    String errorMessage    = (String) request.getAttribute("errorMessage");
    String errorType       = (String) request.getAttribute("errorType");
    String searchedId      = (String) request.getAttribute("searchedId");
    String exceptionDetail = (String) request.getAttribute("exceptionDetail");

    /* ======= Also check Tomcat's standard error attributes ======= */
    Integer httpStatusCode  = (Integer) request.getAttribute("javax.servlet.error.status_code");
    String  errorUri        = (String)  request.getAttribute("javax.servlet.error.request_uri");
    Throwable throwable     = (Throwable) request.getAttribute("javax.servlet.error.exception");

    /* ======= Derive display values ======= */
    String displayTitle   = "Something Went Wrong";
    String displayIcon    = "⚠️";
    String displayCode    = "ERROR";

    if ("validation".equals(errorType)) {
        displayTitle = "Invalid Input";
        displayIcon  = "📋";
        displayCode  = "VALIDATION ERROR";
    } else if ("database".equals(errorType)) {
        displayTitle = "Database Error";
        displayIcon  = "🗄️";
        displayCode  = "DATABASE ERROR";
    } else if ("notfound".equals(errorType)) {
        displayTitle = "Shipment Not Found";
        displayIcon  = "🔍";
        displayCode  = "NOT FOUND";
    } else if (httpStatusCode != null) {
        if (httpStatusCode == 404) {
            displayTitle = "Page Not Found";
            displayIcon  = "🗺️";
            displayCode  = "404";
            if (errorMessage == null) errorMessage = "The page you are looking for does not exist.";
        } else if (httpStatusCode == 500) {
            displayTitle = "Internal Server Error";
            displayIcon  = "💥";
            displayCode  = "500";
            if (errorMessage == null) errorMessage = "An internal error occurred. Please try again.";
        }
    }

    if (errorMessage == null || errorMessage.isEmpty()) {
        errorMessage = "An unexpected error occurred. Please try again or contact support.";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%= displayCode %> — CargoTrack Pro</title>
    <meta name="description" content="Error page - CargoTrack Pro Shipment Tracker">

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
        <a class="navbar-brand" href="index.jsp" id="nav-brand-error">
            <span class="brand-icon">📦</span>
            CargoTrack Pro
        </a>
    </div>
</nav>

<!-- ======================== ERROR CONTENT ======================== -->
<div class="error-container">
    <div class="container">
        <div class="row justify-content-center">
            <div class="col-12 col-md-8 col-lg-6">

                <div class="error-card" id="error-display-card">

                    <!-- Error Icon -->
                    <div class="error-icon" id="error-icon" aria-hidden="true">
                        <%= displayIcon %>
                    </div>

                    <!-- Error Code Badge -->
                    <div class="error-code" id="error-code-label"><%= displayCode %></div>

                    <!-- Title -->
                    <h1 class="error-title" id="error-title"><%= displayTitle %></h1>

                    <!-- Message -->
                    <div class="error-message" id="error-message">
                        <%= errorMessage %>
                    </div>

                    <!-- Extra info for not-found -->
                    <% if (searchedId != null && !searchedId.isEmpty()) { %>
                    <div style="background:rgba(239,68,68,0.06); border:1px solid rgba(239,68,68,0.2);
                                border-radius:var(--radius-md); padding:0.75rem 1rem;
                                margin-bottom:1.5rem; font-size:0.875rem; color:var(--text-secondary);">
                        <i class="bi bi-upc-scan" style="color:var(--danger);"></i>
                        &nbsp;Searched ID: <strong style="color:var(--text-primary);"><%= searchedId %></strong>
                    </div>
                    <% } %>

                    <!-- Helpful tip for not-found -->
                    <% if ("notfound".equals(errorType)) { %>
                    <div style="background:rgba(0,212,255,0.06); border:1px solid rgba(0,212,255,0.15);
                                border-radius:var(--radius-md); padding:0.75rem 1rem;
                                margin-bottom:1.5rem; font-size:0.82rem; color:var(--text-secondary); text-align:left;">
                        <strong style="color:var(--primary);">💡 Try these sample IDs:</strong><br>
                        <span class="tag" style="margin-top:0.4rem; display:inline-block;">CST001</span>&nbsp;
                        <span class="tag">CST002</span>&nbsp;
                        <span class="tag">CST003</span>&nbsp;
                        <span class="tag">CST004</span>&nbsp;
                        <span class="tag">CST005</span>
                    </div>
                    <% } %>

                    <!-- Technical details (DB errors only) -->
                    <% if ("database".equals(errorType) && exceptionDetail != null) { %>
                    <details style="margin-bottom:1.5rem; text-align:left;">
                        <summary style="font-size:0.8rem; color:var(--text-muted); cursor:pointer; padding:0.5rem; border-radius:4px;">
                            <i class="bi bi-bug"></i> Technical Details
                        </summary>
                        <div style="background:var(--bg-input); border-radius:var(--radius-sm); padding:0.75rem;
                                    font-size:0.75rem; color:var(--danger); font-family:monospace;
                                    margin-top:0.5rem; word-break:break-all;">
                            <%= exceptionDetail %>
                        </div>
                    </details>
                    <% } %>

                    <!-- Exception from Tomcat (HTTP errors with throwable) -->
                    <% if (throwable != null && !"notfound".equals(errorType) && !"database".equals(errorType)) { %>
                    <details style="margin-bottom:1.5rem; text-align:left;">
                        <summary style="font-size:0.8rem; color:var(--text-muted); cursor:pointer;">
                            <i class="bi bi-bug"></i> Exception Details
                        </summary>
                        <div style="background:var(--bg-input); border-radius:var(--radius-sm); padding:0.75rem;
                                    font-size:0.75rem; color:var(--danger); font-family:monospace;
                                    margin-top:0.5rem; word-break:break-all;">
                            <%= throwable.getClass().getName() %>: <%= throwable.getMessage() %>
                        </div>
                    </details>
                    <% } %>

                    <!-- Action buttons -->
                    <div style="display:flex; gap:0.75rem; justify-content:center; flex-wrap:wrap;">
                        <a href="index.jsp" class="btn-primary-custom" id="btn-go-home"
                           style="width:auto; padding:0.75rem 1.75rem;">
                            <i class="bi bi-house-door"></i> Go Home
                        </a>
                        <button onclick="history.back()" class="btn-secondary-custom" id="btn-go-back">
                            <i class="bi bi-arrow-left"></i> Go Back
                        </button>
                    </div>

                </div><!-- /error-card -->

                <!-- Help text -->
                <p style="text-align:center; font-size:0.8rem; color:var(--text-muted); margin-top:1.5rem;">
                    Need help? The system currently tracks shipments IDs loaded in the database.
                    <br>Make sure MySQL is running and the cargo_tracker database is set up.
                </p>

            </div>
        </div>
    </div>
</div>

<!-- ======================== FOOTER ======================== -->
<footer class="footer">
    <div class="container">
        <p class="footer-text">
            &copy; 2025 <strong style="color:var(--primary);">CargoTrack Pro</strong>
        </p>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
