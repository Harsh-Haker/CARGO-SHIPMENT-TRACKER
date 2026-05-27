# 📦 CargoTrack Pro — Real-Time Cargo Shipment Tracker

A premium, modern logistics shipment tracking portal built using native **Java Web Technologies (MVC, Servlets, JSP, JDBC)** and **MySQL**. It demonstrates clean design principles, robust database practices, session-based search persistence, and cookie-based user preference mapping.

---

## 🚀 Key Features

* **Real-Time Tracking Dashboard**: Look up shipments instantly and view comprehensive status, expected delivery date, origin/destination cities, and current locations.
* **Visual Status Stepper**: A highly interactive, beautifully styled progress indicator representing the six key logistics milestones:
  `Order Placed` ➔ `Packed` ➔ `In Transit` ➔ `Arrived at Hub` ➔ `Out for Delivery` ➔ `Delivered`
* **Session Search History**: Keeps track of recent queries during the user session for lightning-fast comparisons and navigation.
* **Cookie-Based Persistence**: Remembers the customer's name across visits to greet them with a personalized tracking dashboard.
* **Modern CSS System**: Styled using a premium, harmonic HSL-tailored color palette with smooth micro-animations, glassmorphism, dynamic buttons, and full responsive layout scaling.
* **Security & Reliability**: Implements robust database validation, parameterized queries (SQL injection prevention), and customized error handling page wrappers (`404` & `500`).

---

## 🛠️ Architecture & Tech Stack

This project is built using a strict **MVC (Model-View-Controller)** structural architecture:

* **Model**: Java POJO representation of the domain (`model.Shipment`)
* **View**: Interactive dynamic pages with HSL styles (`index.jsp`, `status.jsp`, `error.jsp`)
* **Controller**: Main servlet routing and input handling (`controller.TrackShipmentServlet`)
* **Data Access**: JDBC-based clean database access object (`dao.ShipmentDAO` and `util.DBConnection`)
* **Database**: MySQL 8.0+ / 9.0+ storing real-time cargo logs
* **Server**: Apache Tomcat 9+

---

## ⚡ Quick Start: One-Click Runner (`run_app.bat`)

For native Windows users, a **One-Click Startup Script** has been created to completely automate compiling, deploying, and booting up the database and Tomcat server:

1. Navigate to your project folder or Desktop.
2. Double-click the **`run_app.bat`** file.
3. This script will automatically:
   * **Recompile** the controller classes.
   * **Deploy** the dynamic pages to your Tomcat `webapps/` folder.
   * **Start** the MySQL server in the background (PIDs managed detached).
   * **Launch** Tomcat 9 in a new console window.
4. Access the live app in your browser at:
   👉 **`http://localhost:8080/CargoShipmentTracker/`**

---

## 🗄️ Database Seeding

The application comes pre-seeded with a rich testing dataset representing diverse logistics states (located inside `database/cargo_tracker.sql`):

* **`CST001`**: Delivered (Rahul Sharma — Mumbai ➔ New Delhi)
* **`CST002`**: Out for Delivery (Priya Patel — Chennai ➔ Bengaluru)
* **`CST003`**: In Transit (Arjun Mehta — Mumbai ➔ Hyderabad)
* **`CST004`**: Arrived at Hub (Sneha Gupta — Delhi ➔ Pune)
* **`CST005`**: Packed (Vikram Singh — Kolkata ➔ Ahmedabad)
* **`CST006`**: Order Placed (Ananya Reddy — Hyderabad ➔ Jaipur)

---

## 📂 Project Structure

```
CargoShipmentTracker/
├── src/
│   ├── controller/      # MVC Controller (TrackShipmentServlet)
│   ├── dao/             # Data Access Object (ShipmentDAO)
│   ├── model/           # Model Object (Shipment POJO)
│   └── util/            # Utility Utilities (DBConnection pool helper)
├── WebContent/
│   ├── css/             # Custom Glassmorphism HSL styling
│   ├── WEB-INF/         # Tomcat Deployment Descriptor (web.xml & dependencies)
│   ├── index.jsp        # Portal Home Page (Search Dashboard)
│   ├── status.jsp       # Tracking Status Stepper View
│   └── error.jsp        # Custom Exception and Error Handler
└── database/
    └── cargo_tracker.sql # MySQL Database Schema & seed script
```

---

## 🛡️ License

This project is open-source and free for personal, educational, and developer reference use.
