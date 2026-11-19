# Intelligent Public Utility Consumption Optimization Platform (IPUCOP)

A full-stack, enterprise-grade web application engineered for real-time monitoring, anomaly detection, leak prevention, predictive forecasting, and cost optimization of public utility consumption (**Electricity**, **Water**, and **Gas**).

---

## 🌟 Key Features

1. **Smart Real-Time Monitoring**:
   - Live telemetry ingestion for Electricity (kWh), Water (Liters), and Gas (m³).
   - Instant computation of today's total, monthly totals, cost projections, and budget utilization.
   - Dynamic **Utility Efficiency Score (0–100)** categorized into *Excellent*, *Good*, *Moderate*, and *Poor*.

2. **Abnormal Consumption Detection Engine**:
   - Statistical moving-average and threshold-based anomaly detection.
   - Accurately detects sudden spikes (e.g. normal 100–150 units/day vs current 220 units/day $\rightarrow$ **+46% alert**).

3. **Intelligent Leak Detection (Water & Gas)**:
   - Detects continuous off-peak night flow (12 AM – 5 AM) and unbroken high-volume pipeline flow over 30 minutes.
   - Triggers high-priority alerts with automated inspection action items.

4. **Multi-Channel Notification Dispatcher**:
   - **LOW Severity**: In-App notification.
   - **MEDIUM Severity**: In-App + Email notification.
   - **HIGH Severity**: In-App + Email + SMS gateway notification.
   - Pluggable SMS architecture supporting active **Twilio REST API** and built-in **Simulation/Console Logger**.

5. **AI Predictive Advisory Module**:
   - Forecasts consumption for **Tomorrow**, **Next Week**, and **Month-End**.
   - Generates early warning alerts if projected usage exceeds monthly budgets (e.g. *18% over-budget alert*).
   - Assesses a current hourly utility reading against its baseline and provides a status, likely cause, recommended action, and saved assessment history.

6. **Smart Recommendation Engine**:
   - Actionable optimization recommendations (peak load shifting, standby power cutoff, AC setpoint adjustment).
   - Displays estimated percentage and dollar savings per recommendation.

7. **Interactive IoT Sensor Simulator**:
   - On-demand injection of normal readings, +46% electricity spikes, water leaks, gas pressure drops, and corrective action resets directly from the dashboard for college viva demonstrations!

---

## 🛠️ Technology Stack

| Layer | Technology |
|---|---|
| **Frontend** | HTML5, CSS3, Modern Vanilla JavaScript, Chart.js |
| **Backend** | Java 17+, Spring Boot 3.3.5, Spring Security 6, Spring Data JPA |
| **Authentication**| JSON Web Tokens (JWT) HMAC-SHA256, BCrypt password hashing |
| **Database** | MySQL 8.x / MariaDB (Persistent H2 fallback for instant out-of-the-box evaluation) |
| **Notifications**| In-App Repository, Spring Mail (SMTP), Twilio / Mock SMS Gateway |
| **Build Tool** | Apache Maven Wrapper (`mvnw.cmd`) |

---

## 🚀 Quick Start Guide

### 1. Prerequisites
- **JDK 17 or higher** installed on your system.

### 2. Run the Application
From the project root directory, run:

```powershell
.\mvnw.cmd spring-boot:run
```

Or build the executable JAR:
```powershell
.\mvnw.cmd clean package -DskipTests=false
java -jar target/ipucop-platform-1.0.0.jar
```

### 3. Access the Web Application
Open your browser and navigate to:
- **Application Portal**: [http://localhost:8080](http://localhost:8080)
- **H2 Database Console**: [http://localhost:8080/h2-console](http://localhost:8080/h2-console)
  - JDBC URL: `jdbc:h2:file:./data/ipucopdb`
  - User: `sa` | Password: *(blank)*

---

## 👤 Default Credentials

| Role | Email | Password | Access Level |
|---|---|---|---|
| **System Admin** | `admin@ipucop.com` | `Admin@123` | Full administrative control, user/sensor CRUD, tariffs, all analytics |
| **Campus User** | `user@ipucop.com` | `User@123` | Personal dashboard, alerts, recommendations, predictions, budget tracking |

*(Quick-Fill demo buttons are available on the login page for 1-click viva testing).*

---

## 🧪 College Viva Demonstration Script

1. **Login as Admin**: Click **"Demo Admin"** on the login page and sign in.
2. **Observe Real-Time Dashboard**:
   - Note the **Utility Efficiency Score (90-100: Excellent)**.
   - Review the Chart.js telemetry lines for Electricity, Water, and Gas.
3. **Simulate Abnormal Consumption (+46% Spike)**:
   - Click the yellow **"⚠️ Electricity Spike (+46%)"** button in the Simulator Widget.
   - Observe the alert banner appear immediately.
   - Check the notification bell: In-App, Email, and SMS have been dispatched!
4. **Simulate Water Leak**:
   - Click the red **"🚨 Water Leak (High Flow)"** button.
   - Notice the high-priority **"🚨 Possible Water Leak Detected"** alert.
5. **View Notification & SMS Audit Log**:
   - Click **"Alerts & History"** in the sidebar $\rightarrow$ switch to **"Multi-Channel Dispatch Audit Log"**.
   - Show the evaluator the exact SMS payload, recipient phone numbers, and delivery status.
6. **Execute Corrective Action**:
   - Click **"✅ Corrective Action (Resolve & Reset)"** in the simulator.
   - Active alerts resolve, and the system restores normal baseline readings.
7. **View Predictions & Budgets**:
   - Navigate to **"Utility Budgets"** to show the 18% over-budget forecast and tomorrow's predictive estimates.

---

## 🗄️ MySQL Database Setup (Optional Production Profile)

To connect IPUCOP to a local MySQL instance:
1. Create database in MySQL:
   ```sql
   CREATE DATABASE ipucop_db;
   ```
2. Run `schema-mysql.sql` and `data-mysql.sql` in MySQL Workbench or terminal.
3. Launch IPUCOP with the `mysql` profile:
   ```powershell
   java -jar target/ipucop-platform-1.0.0.jar --spring.profiles.active=mysql
   ```

---

## 📄 Project Documentation

For a comprehensive final-year college project report, system architecture diagrams, mathematical anomaly detection formulas, database ER diagrams, and viva Q&A preparation, consult [`PROJECT_DOCUMENTATION.md`](PROJECT_DOCUMENTATION.md).
