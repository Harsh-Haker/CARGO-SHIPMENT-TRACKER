package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 * DBConnection.java
 * Utility class for managing MySQL database connections using JDBC.
 * Implements Singleton-style connection helper.
 *
 * MVC Layer: Utility / Infrastructure
 *
 * @author CargoShipmentTracker
 * @version 1.0
 */
public class DBConnection {

    // ===================== DATABASE CONFIGURATION =====================
    // Update these credentials to match your local MySQL setup
    private static final String DRIVER_CLASS   = "com.mysql.cj.jdbc.Driver";
    private static final String DB_URL         = "jdbc:mysql://localhost:3306/cargo_tracker?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String DB_USER        = "root";         // Change to your MySQL username
    private static final String DB_PASSWORD    = "Harsh@9444";         // Change to your MySQL password

    // ===================== STATIC INITIALIZER =====================
    static {
        try {
            // Load JDBC driver class once when this class is loaded
            Class.forName(DRIVER_CLASS);
            System.out.println("[DBConnection] MySQL JDBC Driver loaded successfully.");
        } catch (ClassNotFoundException e) {
            System.err.println("[DBConnection] ERROR: MySQL JDBC Driver not found!");
            System.err.println("  >> Make sure mysql-connector-j-*.jar is in WEB-INF/lib/");
            throw new ExceptionInInitializerError(e);
        }
    }

    /**
     * Opens and returns a new JDBC Connection to the cargo_tracker database.
     *
     * @return  A live {@link Connection} object
     * @throws  SQLException if the connection cannot be established
     */
    public static Connection getConnection() throws SQLException {
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        System.out.println("[DBConnection] Database connection established.");
        return conn;
    }

    /**
     * Safely closes a database connection.
     * Null-safe - passing null is a no-op.
     *
     * @param conn  The {@link Connection} to close
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
                System.out.println("[DBConnection] Database connection closed.");
            } catch (SQLException e) {
                System.err.println("[DBConnection] Warning: Failed to close connection - " + e.getMessage());
            }
        }
    }

    // ===================== TEST MAIN =====================
    /**
     * Quick standalone test - run as Java application to verify DB connectivity.
     */
    public static void main(String[] args) {
        System.out.println("Testing database connection...");
        Connection conn = null;
        try {
            conn = getConnection();
            System.out.println("SUCCESS: Connected to cargo_tracker database!");
            System.out.println("Catalog: " + conn.getCatalog());
        } catch (SQLException e) {
            System.err.println("FAILED: " + e.getMessage());
        } finally {
            closeConnection(conn);
        }
    }
}
