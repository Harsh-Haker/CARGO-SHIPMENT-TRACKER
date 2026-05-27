package controller;

import dao.ShipmentDAO;
import model.Shipment;

import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * TrackShipmentServlet.java
 * Main Controller in the MVC Architecture.
 *
 * Handles both GET and POST requests for shipment tracking.
 * Responsibilities:
 *   - Validate form input
 *   - Call DAO to fetch shipment from database
 *   - Store/retrieve cookies (customer name persistence)
 *   - Manage session (recent search history)
 *   - Forward results to appropriate JSP view
 *
 * URL Mapping: /trackShipment
 *
 * @author CargoShipmentTracker
 * @version 1.0
 */
// @WebServlet("/trackShipment")
public class TrackShipmentServlet extends HttpServlet {

    private static final long serialVersionUID = 1L;

    // ===================== CONSTANTS =====================
    /** Maximum number of recent searches to keep in session */
    private static final int MAX_RECENT_SEARCHES = 3;

    /** Cookie name used to persist customer's name */
    private static final String COOKIE_NAME = "customerName";

    /** Cookie expiration: 7 days in seconds */
    private static final int COOKIE_MAX_AGE = 7 * 24 * 60 * 60;

    /** Session attribute key for recent searches list */
    private static final String SESSION_RECENT_SEARCHES = "recentSearches";

    // ===================== DAO =====================
    private ShipmentDAO shipmentDAO;

    /** Initialize DAO once when servlet is loaded */
    @Override
    public void init() throws ServletException {
        shipmentDAO = new ShipmentDAO();
        System.out.println("[TrackShipmentServlet] Servlet initialized. DAO ready.");
    }

    // ===================== doGet =====================
    /**
     * Handles HTTP GET requests.
     * Used when user clicks a recent search link or navigates directly via URL.
     *
     * @param request   HttpServletRequest containing query parameters
     * @param response  HttpServletResponse
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("[TrackShipmentServlet] doGet() called.");
        String shipmentId = request.getParameter("shipmentId");

        if (shipmentId != null && !shipmentId.trim().isEmpty()) {
            // Process the tracking request just like a POST
            processTrackingRequest(request, response, shipmentId.trim(), null);
        } else {
            // No shipment ID provided - redirect back to home
            System.out.println("[TrackShipmentServlet] GET: No shipment ID, redirecting to home.");
            response.sendRedirect(request.getContextPath() + "/index.jsp");
        }
    }

    // ===================== doPost =====================
    /**
     * Handles HTTP POST requests.
     * Called when user submits the search form on index.jsp.
     *
     * @param request   HttpServletRequest containing form data
     * @param response  HttpServletResponse
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        System.out.println("[TrackShipmentServlet] doPost() called.");

        // --- 1. Read form parameters ---
        String shipmentId    = request.getParameter("shipmentId");
        String customerName  = request.getParameter("customerName");

        // --- 2. Basic validation ---
        if (shipmentId == null || shipmentId.trim().isEmpty()) {
            System.out.println("[TrackShipmentServlet] Validation failed: empty shipment ID.");
            request.setAttribute("errorMessage", "Please enter a valid Shipment ID.");
            request.setAttribute("errorType", "validation");
            forwardToError(request, response);
            return;
        }

        // --- 3. Manage Cookie: save customer name ---
        if (customerName != null && !customerName.trim().isEmpty()) {
            Cookie nameCookie = new Cookie(COOKIE_NAME, customerName.trim());
            nameCookie.setMaxAge(COOKIE_MAX_AGE);
            nameCookie.setPath("/");        // Available across entire application
            response.addCookie(nameCookie);
            System.out.println("[TrackShipmentServlet] Cookie set: " + COOKIE_NAME + "=" + customerName.trim());
        }

        // --- 4. Process the tracking request ---
        processTrackingRequest(request, response, shipmentId.trim(), customerName);
    }

    // ===================== CORE PROCESSING =====================
    /**
     * Central method called by both doGet() and doPost().
     * Fetches shipment data, updates session, and forwards to view.
     *
     * @param request       HttpServletRequest
     * @param response      HttpServletResponse
     * @param shipmentId    The shipment ID to look up (already trimmed)
     * @param customerName  Customer name from form (may be null for GET requests)
     */
    @SuppressWarnings("unchecked")
    private void processTrackingRequest(HttpServletRequest request,
                                        HttpServletResponse response,
                                        String shipmentId,
                                        String customerName)
            throws ServletException, IOException {

        // --- Step 1: Fetch shipment from database ---
        Shipment shipment = null;
        try {
            shipment = shipmentDAO.findByShipmentId(shipmentId);
        } catch (SQLException e) {
            System.err.println("[TrackShipmentServlet] SQLException: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage",
                "A database error occurred. Please try again later.");
            request.setAttribute("errorType", "database");
            request.setAttribute("exceptionDetail", e.getMessage());
            forwardToError(request, response);
            return;
        }

        // --- Step 2: Handle not-found case ---
        if (shipment == null) {
            System.out.println("[TrackShipmentServlet] Shipment not found: " + shipmentId);
            request.setAttribute("errorMessage",
                "No shipment found with ID: <strong>" + escapeHtml(shipmentId) + "</strong>. "
                + "Please check the ID and try again.");
            request.setAttribute("errorType", "notfound");
            request.setAttribute("searchedId", escapeHtml(shipmentId));
            forwardToError(request, response);
            return;
        }

        // --- Step 3: Update Session - Recent Searches ---
        HttpSession session = request.getSession(true); // create if not exists
        List<String> recentSearches =
            (List<String>) session.getAttribute(SESSION_RECENT_SEARCHES);

        if (recentSearches == null) {
            recentSearches = new ArrayList<>();
        }

        // Remove duplicate if already present (keep most-recent at front)
        recentSearches.remove(shipmentId.toUpperCase());

        // Add new search at the beginning
        recentSearches.add(0, shipmentId.toUpperCase());

        // Trim to maximum allowed recent searches
        if (recentSearches.size() > MAX_RECENT_SEARCHES) {
            recentSearches = recentSearches.subList(0, MAX_RECENT_SEARCHES);
        }

        session.setAttribute(SESSION_RECENT_SEARCHES, recentSearches);
        System.out.println("[TrackShipmentServlet] Session updated. Recent searches: " + recentSearches);

        // --- Step 4: Read back customer name from Cookie if not provided ---
        if (customerName == null || customerName.trim().isEmpty()) {
            customerName = getCustomerNameFromCookie(request);
        }

        // --- Step 5: Attach data to request and forward to status.jsp ---
        request.setAttribute("shipment",      shipment);
        request.setAttribute("recentSearches", recentSearches);
        request.setAttribute("customerNameFromCookie", customerName);

        System.out.println("[TrackShipmentServlet] Forwarding to status.jsp for shipment: " + shipmentId);
        RequestDispatcher dispatcher = request.getRequestDispatcher("/status.jsp");
        dispatcher.forward(request, response);
    }

    // ===================== PRIVATE HELPERS =====================

    /**
     * Reads the customer name from cookies in the request.
     *
     * @param  request  HttpServletRequest
     * @return Customer name string, or empty string if no cookie found
     */
    private String getCustomerNameFromCookie(HttpServletRequest request) {
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (COOKIE_NAME.equals(cookie.getName())) {
                    System.out.println("[TrackShipmentServlet] Cookie found: " + cookie.getValue());
                    return cookie.getValue();
                }
            }
        }
        return "";
    }

    /**
     * Forwards the request to error.jsp.
     *
     * @param  request   HttpServletRequest (with error attributes already set)
     * @param  response  HttpServletResponse
     */
    private void forwardToError(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        RequestDispatcher dispatcher = request.getRequestDispatcher("/error.jsp");
        dispatcher.forward(request, response);
    }

    /**
     * Minimal HTML escaping to prevent XSS when displaying user input.
     *
     * @param  input  Raw user-provided string
     * @return HTML-safe string
     */
    private String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&",  "&amp;")
                    .replace("<",  "&lt;")
                    .replace(">",  "&gt;")
                    .replace("\"", "&quot;")
                    .replace("'",  "&#x27;");
    }

    /** Called when servlet is unloaded */
    @Override
    public void destroy() {
        System.out.println("[TrackShipmentServlet] Servlet destroyed.");
    }
}
