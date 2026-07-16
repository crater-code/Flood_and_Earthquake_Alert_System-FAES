# Software Requirements Specification (SRS)

## Flood and Earthquake Alert System (FAEAS)

---

## 1. Introduction

### 1.1 Purpose
This document defines the functional and non-functional requirements for the Flood and Earthquake Alert System (FAEAS). It serves as the single source of truth for development, testing, and deployment.

### 1.2 Scope
FAEAS is a real-time disaster reporting and alert system that:
- Allows users to report disasters (floods, earthquakes)
- Verifies reports using AI + external APIs
- Sends alerts to nearby users
- Provides NGO tools for disaster management

---

## 2. System Overview

### 2.1 Core Problem
Existing systems:
- Lack human input
- Are decentralized (multiple apps needed)
- Provide unverified alerts

### 2.2 Solution
FAEAS introduces:
- Two-way communication (user ↔ system)
- AI-based report verification
- Centralized disaster information platform

---

## 3. User Roles

### 3.1 Citizen
- Reports disasters
- Receives alerts
- Interacts with community hub

### 3.2 NGO
- Monitors verified reports
- Manages resources
- Uses map analytics

---

## 4. Functional Requirements

### F-01: User Authentication
- Users can register/login
- Role-based access (Citizen / NGO)
- Secure session handling

---

### F-02: Disaster Reporting
- Users can submit:
  - Disaster type (Flood / Earthquake)
  - Location (GPS/manual)
  - Description
  - Media (optional)

---

### F-03: AI-Based Verification
- System verifies reports using:
  - Weather APIs
  - News APIs
  - NLP models
- Assigns credibility score

---

### F-04: Alert Generation
- Alerts triggered when:
  - Report credibility > threshold
- Alerts include:
  - Location
  - Severity
  - Instructions

---

### F-05: Community Hub
- Users can:
  - View reports
  - Upvote/downvote
  - Impacts credibility score

---

### F-06: Map Visualization
- Interactive map showing:
  - Disaster locations
  - Heatmaps
  - Safe zones / routes

---

### F-07: NGO Resource Management
- NGOs can:
  - Add resources (food, shelter, etc.)
  - Track distribution
  - View affected zones

---

### F-08: AI Chatbot
- Answers:
  - Safety instructions
  - Reporting guidance
  - Disaster info

---

### F-09: Notifications
- Push notifications for:
  - Alerts
  - Updates
  - NGO communications

---

## 5. External Interfaces

### 5.1 User Interface
- Mobile (Flutter)
- Web dashboard

### 5.2 APIs
- Weather API (e.g., OpenWeather)
- News API
- Notification service (Firebase)

### 5.3 Hardware
- GPS (location tracking)
- Mobile device sensors

---

## 6. Non-Functional Requirements

### 6.1 Performance
- Alerts must be delivered within seconds
- System should handle high concurrent users

### 6.2 Security
- Encrypted user data
- Secure authentication (JWT/session tokens)
- Protection against spam reports

### 6.3 Reliability
- System uptime ≥ 99%
- Fail-safe alert delivery

### 6.4 Usability
- Simple UI for non-technical users
- Fast navigation during emergencies

### 6.5 Scalability
- Must support large-scale disaster scenarios

### 6.6 Maintainability
- Modular architecture
- Clean API structure

---

## 7. Constraints
- Internet dependency
- API rate limits
- Accuracy depends on external data sources

---

## 8. Assumptions
- Users have smartphones
- GPS is enabled
- APIs are available

---

## 9. Future Enhancements
- More disaster types (fires, landslides)
- Offline mode
- Predictive analytics using ML

---

## 10. Success Criteria
System is successful if:
- Users receive timely alerts
- Reports are accurate
- NGOs can respond faster

---
