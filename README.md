# FAES — Flood & Earthquake Alert System

[![Flutter](https://img.shields.io/badge/Flutter-v3.47.5-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-v3.13.4-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
[![Backend](https://img.shields.io/badge/Backend-Node.js_%7C_Express_5.x-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![Database ORM](https://img.shields.io/badge/ORM-Prisma_7.x-2D3748?logo=prisma&logoColor=white)](https://www.prisma.io/)
[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Maps](https://img.shields.io/badge/Maps-OpenStreetMap_%2F_flutter__map-7EBC6F?logo=openstreetmap&logoColor=white)](https://www.openstreetmap.org/)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

An enterprise-grade, real-time disaster warning, rapid emergency response, and community resilience ecosystem engineered with **Flutter**, **Dart**, **Node.js/Express**, and **Prisma ORM**. FAES delivers sub-second push notifications for seismic tremors and hydrological flood depths, crowdsourced GPS disaster incident reporting, GIS hazard heatmaps, an AI disaster safety assistant, and dedicated operational dashboards for NGOs and first responders.

---

## 📑 Table of Contents

- [Overview & Problem Statement](#-overview--problem-statement)
- [Key Features](#-key-features)
- [System Architecture](#-system-architecture)
- [Screens & Application Modules](#-screens--application-modules)
- [Application Screenshots & UI Showcase](#-application-screenshots--ui-showcase)
- [Project Directory Structure](#-project-directory-structure)
- [User Roles & Permissions](#-user-roles--permissions)
- [Demo Mode & Test Credentials](#-demo-mode--test-credentials)
- [Local Development Setup](#-local-development-setup)
- [Backend Setup (Node.js + Prisma)](#-backend-setup-nodejs--prisma)
- [👥 Contributors](#-contributors)
- [📄 License](#-license)

---

## 🌟 Overview & Problem Statement

### The Problem
Traditional disaster management systems suffer from critical limitations:
1. **Unidirectional Communication**: Government sirens and broadcast alerts deliver one-way warnings without human-in-the-loop ground feedback.
2. **Fragmented Ecosystems**: Citizens must juggle separate weather apps, news portals, and social media feeds during emergencies.
3. **Unverified Information**: Rumors and unverified crisis reports flood social channels, overwhelming first responders with false alarms.

### The FAES Solution
FAES centralizes disaster telemetry into a cohesive, bi-directional emergency platform:
- **Two-Way Crowdsourcing**: Citizens capture and report disaster incidents with verified GPS coordinates, severity markers, and photographic evidence.
- **AI & Community Verification**: Incidents are corroborated through automated weather telemetry, NLP credibility scoring, and community upvote/downvote signals.
- **NGO Resource Coordination**: Relief organizations deploy emergency aid (food, clean water, medical kits, tents) and monitor field distribution in real time.
- **Zero-Network Offline Fallback**: Built-in offline resilience ensures emergency survival guides, first-aid steps, and hotlines remain fully accessible when telecommunication networks fail.

---

## 🚀 Key Features

- 🌊 **Hydrological & Seismic Telemetry**: Real-time river water levels, flood risk gauges, and seismic magnitude tracking.
- 🗺️ **GIS Hazard Heatmaps**: Interactive maps powered by OpenStreetMap (`flutter_map`) displaying active hazard clusters, safe evacuation zones, and rescue paths.
- 🚨 **One-Tap Emergency Reporting**: Rapid incident logging with GPS geocoding, severity grading (`LOW`, `MEDIUM`, `HIGH`, `CRITICAL`), and camera attachments.
- 🤖 **AI Disaster Assistant**: Intelligent safety advisor guiding users through earthquake drop-cover-hold procedures, flood evacuation routes, and survival checklists.
- 🤝 **Community Aid Hub**: Mutual-aid broadcast feed where stranded citizens request rescue and volunteers coordinate neighborhood assistance.
- 📦 **NGO Aid & Inventory Logistics**: Relief supply ledger tracking medical kits, ration packets, emergency shelters, and relief distribution points.
- 📞 **One-Touch Emergency Hotlines**: Immediate speed-dial directory for rescue agencies (1122, NDMA, PDMA, Edhi, Red Crescent).
- 🎯 **GPS Geofence Calibration**: User-configurable alert radius (10km to 100km) to suppress out-of-region noise and prioritize hyper-local dangers.

---

## 🏗️ System Architecture

```text
┌────────────────────────────────────────────────────────┐
│               FLUTTER MULTI-PLATFORM CLIENT             │
│    (Android APK • iOS • Web Server • Windows Desktop)   │
└───────────────┬────────────────────────┬───────────────┘
                │                        │
       [REST API / JSON]          [Local Offline Cache]
                │                        │
                ▼                        ▼
┌───────────────────────────────┐ ┌──────────────────────┐
│     NODE.JS / EXPRESS API     │ │  SharedPreferences   │
│  - JWT Authentication         │ │  - Offline Survival  │
│  - Incident Triage Engine     │ │  - Emergency Guides  │
│  - Role Verification (RBAC)   │ │  - Cached Contacts   │
└───────────────┬───────────────┘ └──────────────────────┘
                │
         [Prisma ORM]
                │
                ▼
┌───────────────────────────────┐
│     POSTGRESQL DATABASE       │
│  - Users, Reports, Resources  │
│  - Geospatial Coordinates     │
└───────────────────────────────┘
```

---

## 📱 Screens & Application Modules

| Screen | File Path | Core Functionality |
|---|---|---|
| **Dashboard** | `lib/screens/home_screen.dart` | Real-time disaster overview, emergency status cards, and live weather alerts |
| **Interactive Map** | `lib/screens/map_screen.dart` | OpenStreetMap GIS visualization, disaster markers, safe corridors, and heatmaps |
| **Incident Reporting** | `lib/screens/report_screen.dart` | Multi-step disaster submission with GPS coordinate capture and photo upload |
| **AI Safety Bot** | `lib/screens/ai_chatbot_screen.dart` | Natural language emergency assistant answering survival questions and first aid |
| **Community Feed** | `lib/screens/community_screen.dart` | Public crowdsourced disaster posts, upvoting, commenting, and updates |
| **NGO Dashboard** | `lib/screens/ngo_dashboard_screen.dart` | Organizational oversight, verified report triage, and field team deployment |
| **Inventory Manager**| `lib/screens/inventory_management_screen.dart` | Relief supplies tracking (Medical, Food, Shelter, Clean Water) |
| **Hotlines Directory**| `lib/screens/hotline_screen.dart` | 1-tap call triggers for Rescue 1122, Edhi, NDMA, and local emergency centers |
| **Location Calibration**| `lib/screens/location_calibration_screen.dart` | Geofence radius slider (10km - 100km) and manual coordinate override |
| **Authentication** | `lib/screens/login_screen.dart` | Secure Citizen vs. NGO role login and registration |

---

## 📸 Application Screenshots & UI Showcase

Visual previews of FAES across desktop command views and responsive mobile screens:

### 🖥️ Desktop Command Dashboards

#### 1. Citizen Dashboard & Real-Time Weather Telemetry
![Citizen Dashboard Desktop](screenshots/FAES_HERO_DESK.png)

* **Module**: Citizen Operations Home (`lib/screens/home_screen.dart`)
* **Description**: Real-time disaster prevention and weather telemetry center. Displays live ambient temperature readings, predictive 5-day weather forecasts, atmospheric humidity (47%), wind velocity (12 km/h), barometric pressure (1013 hPa), and UV index indicators alongside quick-action emergency links.

#### 2. Crisis Command Center (NGO Operations)
![Crisis Command Center Desktop](screenshots/FAES_ngo_DESK.png)

* **Module**: NGO Operations Command (`lib/screens/ngo_dashboard_screen.dart`)
* **Description**: Dedicated crisis operations dashboard for NGOs and emergency responders. Features real-time incident monitoring, categorized triage metrics (Total Reports: 5, High-Severity Alerts requiring urgent action, In-Progress missions, and Resolved incidents), with rapid deployment oversight.

---

### 📱 Mobile Experience

| Citizen Mobile Dashboard | Interactive GIS Disaster Map & Actions |
|:---:|:---:|
| ![Citizen Mobile Dashboard](screenshots/FAES_MOBILE.png) | ![Interactive Disaster Map](screenshots/map_mobile.png) |
| **Mobile Weather & Incident Dashboard**<br>Adaptive mobile layout displaying hyper-local environmental telemetry, dynamic weather forecasting cards, and accessible bottom navigation for quick single-handed emergency triage. | **GIS Disaster Mapping & Quick Drawer**<br>OpenStreetMap GIS visualization with real-time GPS beacon positioning, terrain contours, and expandable action sheet for relief inventory, post updates, and hazard heatmaps. |

---

## 📁 Project Directory Structure

```text
Flood_and_Earthquake_Alert_System-FAES/
├── android/                            # Android native configuration & Gradle scripts
├── assets/                             # App icons, splash screens, and vector artwork
│   └── icon/
│       ├── app_icon.png                # Launcher icon
│       └── splash_icon.png             # Splash screen graphic
├── backend/                            # Primary backend directory
├── backend2/                           # Node.js + Express + Prisma backend
│   └── Backend_FYP-master/
│       ├── prisma/                     # Database schema definition
│       │   └── schema.prisma           # PostgreSQL models (User, Report, Resource)
│       ├── src/                        # Express application source
│       │   ├── controllers/            # Route controllers
│       │   ├── routes/                 # Endpoint definitions
│       │   └── app.js                  # Express server entry point
│       └── package.json                # Node dependencies
├── lib/                                # Flutter application source
│   ├── models/                         # Data transfer objects & models
│   ├── screens/                        # UI view screens (15 screen modules)
│   ├── services/                       # API services & local data providers
│   │   ├── api_service.dart            # Mock API & local data provider
│   │   ├── backend_service.dart        # Live Node.js REST API client
│   │   ├── location_service.dart       # GPS geolocator & geocoding handler
│   │   └── weather_service.dart        # Meteorological disaster feeds
│   ├── theme/                          # Material 3 dark/light color schemes
│   ├── widgets/                        # Modular UI components (drawers, navbars, cards)
│   ├── app.dart                        # MaterialApp root & route configuration
│   └── main.dart                       # Flutter entrypoint
├── screenshots/                        # Visual showcase screenshots folder
├── web/                                # Flutter Web compilation assets
├── pubspec.yaml                        # Flutter package dependencies
├── analysis_options.yaml               # Dart linting and static analysis rules
├── APP_READINESS_ASSESSMENT.md         # Comprehensive system readiness audit
├── DEMO_MODE_INSTRUCTIONS.md           # Quick demo mode credentials guide
└── README.md                           # Master documentation
```

---

## 👥 User Roles & Permissions

1. **Citizen Role**:
   - Submit disaster reports with GPS coordinates and images.
   - Access the AI chatbot for emergency instructions.
   - View GIS hazard heatmaps and navigate to nearest safe shelters.
   - Upvote/corroborate ongoing community disaster alerts.
   - Dial 1-tap emergency rescue hotlines.

2. **NGO Organization Role**:
   - Verify, prioritize, and triage citizen disaster reports.
   - Manage relief resource supplies (inventory, distribution, stock levels).
   - Broadcast organizational warnings and situation reports.
   - Monitor high-density impact clusters via map analytics.

---

## 🎮 Demo Mode & Test Credentials

The application includes a fully self-contained **Demo Mode** requiring **zero external network configuration**:

| Role | Email | Password | Features Accessible |
|---|---|---|---|
| **Citizen** | `citizen@demo.com` | `demo123` | Incident reporting, interactive map, community hub, AI safety bot |
| **NGO Organization** | `ngo@demo.com` | `demo123` | Relief supply management, report verification, NGO dashboard |

---

## 💻 Local Development Setup

### Prerequisites
- **Flutter SDK**: v3.0.0 or higher (Tested on `Flutter 3.47.5`)
- **Dart SDK**: v3.0.0 or higher (Tested on `Dart 3.13.4`)
- **Web Browser**: Google Chrome or Microsoft Edge

### Step-by-Step Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/crater-code/Flood_and_Earthquake_Alert_System-FAES.git
   cd Flood_and_Earthquake_Alert_System-FAES
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the Flutter Web Server**:
   ```bash
   flutter run -d web-server --web-port 3007 --web-hostname 0.0.0.0
   ```
   Open **`http://localhost:3007`** in your browser.

4. **Run on Windows Desktop** *(Optional)*:
   ```bash
   flutter run -d windows
   ```

5. **Build Android APK** *(Optional)*:
   ```bash
   flutter build apk --release
   ```

---

## ⚙️ Backend Setup (Node.js + Prisma)

The repository includes a production-ready Express backend located in `backend2/Backend_FYP-master`:

1. **Navigate to the backend directory**:
   ```bash
   cd backend2/Backend_FYP-master
   ```

2. **Install Node dependencies**:
   ```bash
   npm install
   ```

3. **Configure Environment Variables**:
   Create a `.env` file in `backend2/Backend_FYP-master/`:
   ```env
   DATABASE_URL="postgresql://user:password@localhost:5432/faeas_db"
   PORT=5000
   JWT_SECRET="your_jwt_secret_key"
   ```

4. **Run Prisma Migrations**:
   ```bash
   npx prisma migrate dev
   ```

5. **Start the API Server**:
   ```bash
   npm run dev
   ```

---

## 👥 Contributors

- **Lead Developer**: [Muhammad Abdullah Wasim](https://www.linkedin.com/in/muhammad-abdullah-92b50a304/)

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
