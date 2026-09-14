# EduTrack: Integrated Digital System for Academic Workload Management and Analytics

**EduTrack** is a fully responsive, integrated web platform designed to automate the complete lifecycle of academic workloads, analyze academic burden, and manage exam invigilations and graduation projects in educational institutions. The system aims to eliminate paperwork, reduce human errors, prevent scheduling conflicts, and provide a unified digital reference based on Role-Based Access Control (RBAC).

---

## Table of Contents
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [Tech Stack](#tech-stack)
- [Role-Based Access Control (RBAC)](#role-based-access-control-rbac)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [1. Backend Setup (Django)](#1-backend-setup-django)
  - [2. Frontend Setup (Flutter)](#2-frontend-setup-flutter)
- [Team & Supervision](#team--supervision)

---

## Key Features

* **Smart Workload Automation Engine:** Real-time, high-precision calculation of teaching hours, overloads, invigilation duties, and graduation projects.
* **Automated Conflict Detection:** Prevents time and spatial overlaps (instructors and rooms) during allocation and scheduling.
* **Make-up Sessions & Holiday Management:** Handles time variables and automatically excludes central holidays with real-time workload updates.
* **Mutual Notification & Reminder System:** Enables direct alerts and reminders between academic coordinators and instructors to finalize workload submissions.
* **Reporting & Digital Archiving Module:** Generates print-ready official PDF reports with a single click and archives academic term data.
* **Multi-Language Support & Responsiveness:** Complete Arabic and English localization with full cross-device compatibility (Mobile, Tablet, Desktop).

---

## System Architecture

The application adopts a **Layered Architecture** based on the Separation of Concerns principle and a **Feature-First** approach:

1. **Presentation Layer:** Responsive and interactive user interfaces built for web and cross-platform use.
2. **Business Logic Layer:** State management and core business processing handled by `GetX Controllers` and reactive services.
3. **Data Layer:** Data entities (`Models`), REST API integration via Dio/Http, and local state management.

---

## Tech Stack

### Frontend
* **Dart / Flutter:** Cross-platform framework for building responsive web and mobile interfaces from a single codebase.
* **GetX:** State management, dependency injection, and reactive route management.

### Backend
* **Python / Django:** Robust web framework for core server-side logic and business rules.
* **Django REST Framework (DRF):** API engine providing serialization and endpoints for seamless integration.
* **JWT (JSON Web Tokens):** Secure user authentication and stateless session control.

### Database & Tools
* **Microsoft SQL Server / SQL:** Relational database management for enterprise data integrity.
* **Postman:** API development and endpoint testing.
* **VS Code:** Primary Integrated Development Environment (IDE).

---

## Role-Based Access Control (RBAC)

* **System Admin:** Manages system infrastructure, academic calendars, term configurations, central holidays, faculties, departments, room allocations, and user privileges.
* **Academic Coordinator:** Handles course assignments, exam invigilation scheduling, graduation project allocations, workload monitoring, and reminder distributions.
* **Instructor:** Accesses personal schedules, logs attendance and compensation sessions, registers project supervisions, locks finalized workloads, and exports official PDF reports.

---

## Getting Started

### Prerequisites
* **Flutter SDK** (v3.x or higher)
* **Python** (v3.10 or higher)
* **MS SQL Server**
* **Git**

---

### 1. Backend Setup (Django)

1. Clone the repository:
   ```bash
   git clone [https://github.com/your-username/EduTrack-Backend.git](https://github.com/your-username/EduTrack-Backend.git)
   cd EduTrack-Backend
Create and activate a virtual environment:
  Linux/macOS: 
    python3 -m venv venv
    source venv/bin/activate
  Windows:
    python -m venv venv
    venv\Scripts\activate
    
Apply database migrations:
    python manage.py migrate
Run the development server:
  python manage.py runserver

Frontend Setup (Flutter):
  Navigate to the frontend directory:
    cd ../EduTrack-Frontend
  Fetch Flutter packages:
    flutter pub get
  Run the application in Chrome:
    flutter run -d chrome

Team & SupervisionPrepared by: 
Ghofran Al-Shaghri, Khaled Karhoor, and Mohammad Shaghri 
Supervised by: Dr. Ihab Debaja 
Institution: Manara University - Faculty of Engineering - Department of Informatics  

