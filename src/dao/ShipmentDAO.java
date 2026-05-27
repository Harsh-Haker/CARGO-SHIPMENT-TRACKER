package dao;

import model.Shipment;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * ShipmentDAO.java
 * Data Access Object (DAO) for the 'shipments' table.
 * Encapsulates all JDBC operations - part of the Model layer in MVC.
 *
 * All queries use PreparedStatement to prevent SQL Injection.
 *
 * @author CargoShipmentTracker
 * @version 1.0
 */
public class ShipmentDAO {

    // ===================== SQL QUERIES =====================
    /** Fetch a shipment by its business shipment ID */
    private static final String SQL_FIND_BY_SHIPMENT_ID =
        "SELECT id, shipment_id, customer_name, current_location, shipment_status, " +
        "expected_delivery, last_updated, origin_city, destination_city, description " +
        "FROM shipments WHERE shipment_id = ?";

    /** Fetch all shipments for a given customer name (case-insensitive) */
    private static final String SQL_FIND_BY_CUSTOMER =
        "SELECT id, shipment_id, customer_name, current_location, shipment_status, " +
        "expected_delivery, last_updated, origin_city, destination_city, description " +
        "FROM shipments WHERE LOWER(customer_name) LIKE LOWER(?) ORDER BY last_updated DESC";

    /** Fetch all shipments (admin view) */
    private static final String SQL_FIND_ALL =
        "SELECT id, shipment_id, customer_name, current_location, shipment_status, " +
        "expected_delivery, last_updated, origin_city, destination_city, description " +
        "FROM shipments ORDER BY last_updated DESC";

    // ===================== PUBLIC METHODS =====================

    /**
     * Finds a single shipment record by its unique shipment ID string (e.g. "CST001").
     *
     * @param  shipmentId  The business-level shipment identifier
     * @return A populated {@link Shipment} object, or {@code null} if not found
     * @throws SQLException on any database error
     */
    public Shipment findByShipmentId(String shipmentId) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        Shipment shipment = null;

        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(SQL_FIND_BY_SHIPMENT_ID);
            pstmt.setString(1, shipmentId.trim().toUpperCase()); // normalize ID

            System.out.println("[ShipmentDAO] Executing query for shipmentId: " + shipmentId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                shipment = mapRowToShipment(rs);
                System.out.println("[ShipmentDAO] Shipment found: " + shipment);
            } else {
                System.out.println("[ShipmentDAO] No shipment found for ID: " + shipmentId);
            }

        } finally {
            // Always close resources in reverse order
            closeResources(rs, pstmt, conn);
        }

        return shipment;
    }

    /**
     * Finds all shipments belonging to a customer (partial name match).
     *
     * @param  customerName  Customer name (partial or full)
     * @return List of matching {@link Shipment} objects (may be empty)
     * @throws SQLException on any database error
     */
    public List<Shipment> findByCustomerName(String customerName) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Shipment> shipments = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(SQL_FIND_BY_CUSTOMER);
            pstmt.setString(1, "%" + customerName.trim() + "%");

            rs = pstmt.executeQuery();
            while (rs.next()) {
                shipments.add(mapRowToShipment(rs));
            }
            System.out.println("[ShipmentDAO] Found " + shipments.size() + " shipment(s) for customer: " + customerName);

        } finally {
            closeResources(rs, pstmt, conn);
        }

        return shipments;
    }

    /**
     * Retrieves all shipment records from the database.
     *
     * @return List of all {@link Shipment} objects
     * @throws SQLException on any database error
     */
    public List<Shipment> findAll() throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        List<Shipment> shipments = new ArrayList<>();

        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(SQL_FIND_ALL);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                shipments.add(mapRowToShipment(rs));
            }
            System.out.println("[ShipmentDAO] Total shipments retrieved: " + shipments.size());

        } finally {
            closeResources(rs, pstmt, conn);
        }

        return shipments;
    }

    // ===================== PRIVATE HELPERS =====================

    /**
     * Maps the current row of a ResultSet into a {@link Shipment} object.
     * Centralizes column name → field mapping.
     *
     * @param  rs  A ResultSet positioned at a valid row
     * @return Populated {@link Shipment}
     * @throws SQLException if column names are wrong
     */
    private Shipment mapRowToShipment(ResultSet rs) throws SQLException {
        Shipment s = new Shipment();
        s.setId(rs.getInt("id"));
        s.setShipmentId(rs.getString("shipment_id"));
        s.setCustomerName(rs.getString("customer_name"));
        s.setCurrentLocation(rs.getString("current_location"));
        s.setShipmentStatus(rs.getString("shipment_status"));
        s.setExpectedDelivery(rs.getDate("expected_delivery"));
        s.setLastUpdated(rs.getTimestamp("last_updated"));
        s.setOriginCity(rs.getString("origin_city"));
        s.setDestinationCity(rs.getString("destination_city"));
        s.setDescription(rs.getString("description"));
        return s;
    }

    /**
     * Safely closes JDBC resources in proper order.
     *
     * @param rs    ResultSet to close (nullable)
     * @param pstmt PreparedStatement to close (nullable)
     * @param conn  Connection to close (nullable)
     */
    private void closeResources(ResultSet rs, PreparedStatement pstmt, Connection conn) {
        try { if (rs    != null) rs.close();    } catch (SQLException e) { /* ignore */ }
        try { if (pstmt != null) pstmt.close(); } catch (SQLException e) { /* ignore */ }
        DBConnection.closeConnection(conn);
    }
}
