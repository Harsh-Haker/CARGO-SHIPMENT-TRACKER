package model;

import java.sql.Date;
import java.sql.Timestamp;

/**
 * Shipment.java
 * JavaBean Model class representing a shipment record.
 * Follows MVC Architecture - Model Layer.
 *
 * @author CargoShipmentTracker
 * @version 1.0
 */
public class Shipment {

    // ===================== FIELDS =====================
    private int id;
    private String shipmentId;
    private String customerName;
    private String currentLocation;
    private String shipmentStatus;
    private Date expectedDelivery;
    private Timestamp lastUpdated;
    private String originCity;
    private String destinationCity;
    private String description;

    // ===================== CONSTRUCTORS =====================

    /** Default no-arg constructor (required for JavaBean) */
    public Shipment() {
    }

    /** Full parameterized constructor */
    public Shipment(int id, String shipmentId, String customerName,
                    String currentLocation, String shipmentStatus,
                    Date expectedDelivery, Timestamp lastUpdated,
                    String originCity, String destinationCity, String description) {
        this.id = id;
        this.shipmentId = shipmentId;
        this.customerName = customerName;
        this.currentLocation = currentLocation;
        this.shipmentStatus = shipmentStatus;
        this.expectedDelivery = expectedDelivery;
        this.lastUpdated = lastUpdated;
        this.originCity = originCity;
        this.destinationCity = destinationCity;
        this.description = description;
    }

    // ===================== GETTERS & SETTERS =====================

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getShipmentId() { return shipmentId; }
    public void setShipmentId(String shipmentId) { this.shipmentId = shipmentId; }

    public String getCustomerName() { return customerName; }
    public void setCustomerName(String customerName) { this.customerName = customerName; }

    public String getCurrentLocation() { return currentLocation; }
    public void setCurrentLocation(String currentLocation) { this.currentLocation = currentLocation; }

    public String getShipmentStatus() { return shipmentStatus; }
    public void setShipmentStatus(String shipmentStatus) { this.shipmentStatus = shipmentStatus; }

    public Date getExpectedDelivery() { return expectedDelivery; }
    public void setExpectedDelivery(Date expectedDelivery) { this.expectedDelivery = expectedDelivery; }

    public Timestamp getLastUpdated() { return lastUpdated; }
    public void setLastUpdated(Timestamp lastUpdated) { this.lastUpdated = lastUpdated; }

    public String getOriginCity() { return originCity; }
    public void setOriginCity(String originCity) { this.originCity = originCity; }

    public String getDestinationCity() { return destinationCity; }
    public void setDestinationCity(String destinationCity) { this.destinationCity = destinationCity; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    /**
     * Returns the numeric stage index (1-6) corresponding to the shipment status.
     * Used by JSP to highlight the correct timeline stage.
     *
     * Stages:
     *   1 = Order Placed
     *   2 = Packed
     *   3 = In Transit
     *   4 = Arrived at Hub
     *   5 = Out for Delivery
     *   6 = Delivered
     */
    public int getStatusStage() {
        if (shipmentStatus == null) return 0;
        switch (shipmentStatus.trim().toLowerCase()) {
            case "order placed":   return 1;
            case "packed":         return 2;
            case "in transit":     return 3;
            case "arrived at hub": return 4;
            case "out for delivery": return 5;
            case "delivered":      return 6;
            default:               return 0;
        }
    }

    @Override
    public String toString() {
        return "Shipment{" +
                "id=" + id +
                ", shipmentId='" + shipmentId + '\'' +
                ", customerName='" + customerName + '\'' +
                ", currentLocation='" + currentLocation + '\'' +
                ", shipmentStatus='" + shipmentStatus + '\'' +
                ", expectedDelivery=" + expectedDelivery +
                ", lastUpdated=" + lastUpdated +
                '}';
    }
}
