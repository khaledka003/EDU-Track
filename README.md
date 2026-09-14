# EduTrack - Educational & Academic Management System 🎓

**EduTrack** is a comprehensive academic management platform designed to streamline administrative workflows, manage educational roles, and track academic operations efficiently. The system provides role-based access for administrators, staff, and instructors with a modern UI and a robust backend infrastructure.

---

## 🏗️ Project Architecture

The repository is organized into four main modules:

* **`UI/edutrack`**: Mobile application cross-platform client built with **Flutter** (GetX, Dio, Local Storage, Multi-language support).
* **`Back/EduTrack1_`**: Backend RESTful Web API built with **Python & Django REST Framework**.
* **`Data Base`**: Relational database design, schemas, and SQL initialization scripts.
* **`SRS.pdf`**: Comprehensive Software Requirements Specification (SRS) documentation outlining system architecture, use cases, and requirements.

---

## 🌟 Key Features

* 🔐 **Role-Based Access Control (RBAC):** Tailored dashboards and permissions for Admins, Instructors, and Students/Staff.
* 📊 **Management Dashboards:** Real-time tracking of academic records, courses, schedules, and administrative operations.
* 🌐 **Multi-Language Support:** Full localization setup for seamless user experience.
* ⚡ **RESTful API Integration:** High-performance, secure backend communication powered by Django REST Framework and Dio.

---

## 🛠️ Tech Stack

* **Frontend (Mobile):** Flutter, Dart, GetX, Dio
* **Backend (API):** Python, Django, Django REST Framework
* **Database:** Relational Database (MySQL / MariaDB / MS SQL Server)
* **Documentation:** Software Requirements Specification (SRS)

---

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* [Python 3.x](https://www.python.org/) & `pip`
* Database Server (MySQL / SQL Server)

---

### 1. Running the Backend (Django)

```bash
cd "Back/EduTrack1_"

# Create and activate virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Apply database migrations
python manage.py migrate

# Start the server
python manage.py runserver
