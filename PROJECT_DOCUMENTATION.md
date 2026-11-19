# Intelligent Public Utility Consumption Optimization Platform (IPUCOP)
## Comprehensive Academic Project Report & Viva Reference Manual

---

## 1. Abstract

Public utility management in educational institutions, municipalities, and smart commercial facilities faces significant challenges including resource wastage, delayed leak identification, uncoordinated peak-hour loads, and budget overruns. The **Intelligent Public Utility Consumption Optimization Platform (IPUCOP)** is an autonomous full-stack solution engineered to continuously ingest, analyze, predict, and optimize multi-utility consumption across **Electricity**, **Water**, and **Gas**.

Utilizing a Java Spring Boot backend, Spring Security with stateless JSON Web Tokens (JWT), relational database persistence (MySQL/H2), and responsive HTML5/CSS3/Chart.js frontends, IPUCOP establishes automated telemetry monitoring. The platform features mathematical anomaly detection for consumption spikes, specialized continuous-flow heuristic algorithms for pipeline leak detection, time-series predictive forecasting, an automated 0–100 utility efficiency score, rule-based optimization recommendations, and a prioritized multi-channel notification engine (In-App, Email, and SMS).

---

## 2. System Architecture & Design Patterns

IPUCOP adheres to enterprise software engineering standards utilizing a strict **Clean Layered Architecture**:

```
+-----------------------------------------------------------------------------------+
|                           Presentation Layer (Client)                             |
|        HTML5 + CSS3 (Glassmorphism UI) + Vanilla JavaScript (ES6) + Chart.js      |
+-----------------------------------------------------------------------------------+
                                          | HTTP / REST (JSON + JWT)
                                          v
+-----------------------------------------------------------------------------------+
|                        Security & Request Filtering Layer                         |
|     SecurityConfig + JwtAuthenticationFilter + BCryptPasswordEncoder              |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                              Controller / API Layer                               |
| AuthController | ConsumptionController | AlertController | BudgetController etc.  |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                               Service / Business Layer                            |
| ├── AnomalyDetectionService     ├── EfficiencyScoreService                        |
| ├── LeakDetectionService        ├── NotificationService (InApp, Email, SMS)       |
| ├── PredictionService           └── SensorSimulatorService                        |
| └── RecommendationService                                                         |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                            Persistence / Repository Layer                         |
|        Spring Data JPA Interfaces (12 Repositories with Custom JPQL Queries)       |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                                Database Layer                                     |
|                   MySQL 8.x / Persistent H2 Compatibility Engine                  |
+-----------------------------------------------------------------------------------+
```

### Design Patterns Utilized:
1. **Layered Architecture Pattern**: Strict separation of concerns (Presentation, Business, Data Access).
2. **Strategy / Pluggable Notification Pattern**: `SmsService` interface implemented by `TwilioSmsService` and `MockSmsService`, dynamically swappable via configuration.
3. **Data Transfer Object (DTO) Pattern**: Decoupling internal JPA entities from API contracts to prevent over-posting and circular JSON dependencies.
4. **Observer / Dispatcher Pattern**: Alerts automatically notify registered multi-channel communication handlers based on severity level.

---

## 3. Mathematical & Algorithmic Formulations

### 3.1 Abnormal Consumption Detection
Let $C_{\text{actual}}$ denote the units recorded in the current telemetry window, and $\mu_{\text{baseline}}$ represent the expected moving baseline for that specific time/day:

$$\Delta = \left( \frac{C_{\text{actual}} - \mu_{\text{baseline}}}{\mu_{\text{baseline}}} \right) \times 100\%$$

- **Normal**: $\Delta < 20\%$
- **Medium Severity**: $20\% \le \Delta < 40\%$ (Triggers In-App + Email)
- **High Severity (Critical Spike)**: $\Delta \ge 40\%$ (Triggers In-App + Email + SMS)

*Example*: If normal electricity consumption is $150\text{ units/day}$ and recorded consumption reaches $220\text{ units/day}$:
$$\Delta = \frac{220 - 150}{150} \times 100\% = 46.7\% \quad (\ge 40\% \implies \text{HIGH Alert \& SMS Dispatched})$$

### 3.2 Continuous Flow Pipeline Leak Detection
Applicable specifically to fluid and fuel utilities ($\text{Utility} \in \{\text{WATER}, \text{GAS}\}$).
A leak condition is evaluated across two distinct criteria:
1. **Off-Peak Night Continuous Flow**:
   $$\text{Condition}_1 = (t_{\text{hour}} \in [00:00, 05:00]) \land (C_{\text{actual}} > \tau_{\text{night\_threshold}})$$
2. **Sustained Unbroken Flow (Rolling Window)**:
   $$\text{Condition}_2 = \forall i \in \{1, 2, \dots, N\}, \quad C_i > \tau_{\text{flow\_threshold}} \quad \text{where } N \ge 3 \text{ readings}$$

When either condition is satisfied, the system tags the reading as `LEAK` and dispatches a **HIGH Priority Alert**:
> *"🚨 Possible Water Leak Detected: Water consumption has remained unusually high for the last 30 minutes. Please inspect pipelines, taps, and storage tanks."*

### 3.3 Utility Efficiency Score (0–100)
The overall operational score $S$ is initialized at $100$ and reduced by penalized variances:
$$S = 100 - P_{\text{anomalies}} - P_{\text{alerts}}$$
Where:
- $P_{\text{anomalies}} = \min(40, \, N_{\text{anomalies}} \times 5)$
- $P_{\text{alerts}} = \min(35, \, N_{\text{unresolved\_alerts}} \times 7)$
- Normalized score: $S_{\text{final}} = \max(15, \, \min(100, \, S))$

**Score Classification Matrix**:
- $90 \le S \le 100$: **Excellent** (Green)
- $75 \le S < 90$: **Good** (Blue)
- $50 \le S < 75$: **Moderate** (Orange)
- $S < 50$: **Poor** (Red)

### 3.4 Predictive Forecasting & Budget Warning
For daily average $\mu_{\text{daily}}$ calculated over a 7-day rolling window, predictions for day $d$ and days remaining in the month $D_{\text{rem}}$:
- **Tomorrow**: $\hat{C}_{\text{tomorrow}} = \mu_{\text{daily}} \times 1.02$
- **Next Week**: $\hat{C}_{\text{next\_week}} = \mu_{\text{daily}} \times 7$
- **Month-End Projected**: $\hat{C}_{\text{month}} = C_{\text{MTD}} + (\mu_{\text{daily}} \times D_{\text{rem}})$

If $\hat{C}_{\text{month}} > B_{\text{target}}$, the early warning variance is generated:
$$\%_{\text{over\_budget}} = \left( \frac{\hat{C}_{\text{month}} - B_{\text{target}}}{B_{\text{target}}} \right) \times 100\%$$
> *"⚠️ Budget Prediction Alert: Based on current usage, your monthly electricity consumption may exceed the configured budget by approximately 18%."*

---

## 4. Database Relational Model (12 Tables)

| Table Name | Primary Key | Foreign Keys | Purpose |
|---|---|---|---|
| `roles` | `id` | - | Stores authorization roles (`ROLE_ADMIN`, `ROLE_USER`) |
| `buildings` | `id` | - | Campus physical structures (`Block A`, `Block B`, `Block C`) |
| `departments` | `id` | `building_id` | Campus administrative and academic departments |
| `users` | `id` | `role_id`, `building_id`, `dept_id` | User accounts with BCrypt passwords & contact numbers |
| `utilities` | `id` | - | Electricity, Water, Gas with tariff rates & baseline configs |
| `devices` | `id` | `utility_id`, `building_id`, `dept_id` | IoT smart meter hardware registry with live heartbeat ping |
| `consumption_records`| `id`| `device_id`, `utility_id`, `building_id` | Telemetry logs with baseline, cost, and anomaly flags |
| `alerts` | `id` | `utility_id`, `building_id` | System anomalies with severity (`LOW`, `MEDIUM`, `HIGH`) |
| `notifications` | `id` | `user_id`, `alert_id` | Multi-channel dispatch records (`IN_APP`, `EMAIL`, `SMS`) |
| `budgets` | `id` | `utility_id`, `building_id` | Monthly target limits, current spend, and threshold alerts |
| `recommendations` | `id` | `utility_id`, `building_id` | AI optimization actions with potential savings % and $ |
| `utility_predictions`| `id` | `utility_id`, `building_id` | Time-horizon forecasts and saved utility-reading assessments |

---

## 5. REST API Specifications

### 5.1 Authentication
- `POST /api/auth/login`: Authenticates credentials; returns signed JWT Bearer token and user profile.
- `POST /api/auth/register`: Registers a new user account with encrypted password and telephone.
- `GET  /api/auth/me`: Retrieves current authenticated user profile.

### 5.2 Consumption & Analytics
- `POST /api/consumption`: Ingests simulated or physical IoT telemetry readings.
- `GET  /api/consumption/summary`: Returns unified dashboard metrics, KPIs, and efficiency scores.
- `GET  /api/consumption/analytics`: Filterable analytical datasets for Chart.js graphing.

### 5.3 Alerts & Notifications
- `GET  /api/alerts`: Lists all alerts with severity and resolved state filters.
- `PUT  /api/alerts/{id}/read`: Flags alert as viewed.
- `PUT  /api/alerts/{id}/resolve`: Resolves an alert and logs resolution timestamp.
- `GET  /api/notifications`: Retrieves notification history across In-App, Email, and SMS channels.

### 5.4 Budgets, Predictions & Simulator
- `GET  /api/budgets`: Fetches current month budget allocations and utilization percentages.
- `POST /api/budgets`: Creates or updates monthly budget ceilings.
- `GET  /api/predictions`: Fetches tomorrow, next-week, and month-end consumption projections.
- `POST /api/predictions/assess`: Compares a current hourly utility reading with its baseline and returns status, likely cause, and recommended action.
- `GET  /api/predictions/history`: Lists recent saved reading assessments; optionally filter by `utilityId` and `limit` (1–50).
- `POST /api/simulator/tick`: Ingests normal baseline sensor telemetry.
- `POST /api/simulator/spike`: Simulates a +46% electricity consumption surge.
- `POST /api/simulator/leak`: Simulates continuous water pipeline rupture.
- `POST /api/simulator/reset`: Simulates user corrective action resolving alerts.

---

## 6. Viva Voce Preparation Guide (Questions & Answers)

### Q1: What is the primary objective of this project?
**Answer**: IPUCOP is designed to optimize public utility consumption (electricity, water, gas) by ingesting IoT sensor data, detecting abnormal spikes and leaks in real time, projecting future consumption against budgets, and automatically alerting facilities managers via In-App, Email, and SMS notifications.

### Q2: How does the system detect abnormal consumption?
**Answer**: The system compares current telemetry readings against a moving average baseline. If the recorded value exceeds the baseline by $\ge 40\%$, it triggers a HIGH severity alert (e.g. +46% spike alert), automatically storing the alert and dispatching an SMS, Email, and In-App notification.

### Q3: How is leak detection implemented for water and gas?
**Answer**: Leak detection is evaluated by checking continuous flow during unusual night hours (12 AM to 5 AM) or uninterrupted high-flow readings over consecutive 30-minute intervals. If no idle drop is observed, a HIGH severity leak alert is generated with actionable inspection steps.

### Q4: How is security implemented in the backend?
**Answer**: We use Spring Security 6 with stateless JWT authentication. Passwords are encrypted using BCrypt. Each incoming HTTP request is intercepted by `JwtAuthenticationFilter`, which verifies the HMAC-SHA256 signature and populates the `SecurityContext` with the user's role (`ROLE_ADMIN` or `ROLE_USER`).

### Q5: How is the multi-channel notification architecture designed?
**Answer**: We use the Strategy/Service Abstraction pattern via `NotificationService`. Based on alert severity:
- LOW: dispatches to `InAppNotificationService`.
- MEDIUM: dispatches to `InAppNotificationService` + `EmailService`.
- HIGH: dispatches to `InAppNotificationService` + `EmailService` + `SmsService` (Twilio or Mock Gateway).

### Q6: How does the platform function if physical IoT sensors are not available?
**Answer**: IPUCOP features an embedded IoT Sensor Simulator running both autonomously on a Spring `@Scheduled` timer and interactively via dashboard buttons. During project demonstrations, evaluators can click buttons to inject live electricity spikes or water leaks and observe instant SMS/Email alerts and chart updates.
