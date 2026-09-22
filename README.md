cat > README.md << 'EOF'
# 🎓 Student Grade Tracker

A production-ready, containerised 3-tier web application built with
Docker and Docker Compose. It allows students to be added, grades to
be recorded, and class statistics to be viewed in real time.

---

## 📐 Architecture

                ┌─────────────────────────────┐
                │        User (Browser)        │
                └──────────────┬──────────────┘
                               │
                          HTTP :8080
                               │
                ┌──────────────▼───────────── ─┐
                │         FRONTEND             │
                │   nginxinc/nginx-unprivileged│
                │        :1.25-alpine          │
                │                              │
                │  • Serves index.html         │
                │  • Proxies /api/ → backend   │
                │  • Proxies /health → backend │
                │  • Runs as: nginx (non-root) │
                │  • Port: 8080                │
                └──────────────┬──────────────┘
                               │
                     Docker Network
                   grade-tracker-network
                               │
                ┌──────────────▼──────────────┐
                │          BACKEND             │
                │      node:20.11-alpine       │
                │                              │
                │  • REST API (Express.js)     │
                │  • Multi-stage build         │
                │  • GET  /api/students        │
                │  • POST /api/students        │
                │  • GET  /api/grades          │
                │  • POST /api/grades          │
                │  • GET  /health              │
                │  • Runs as: node (non-root)  │
                │  • Port: 3000                │
                └──────────────┬──────────────┘
                               │
                     Docker Network
                   grade-tracker-network
                               │
                ┌──────────────▼──────────────┐
                │          DATABASE            │
                │     postgres:16.2-alpine     │
                │                              │
                │  • Stores students & grades  │
                │  • Seeded via init.sql       │
                │  • Persistent named volume   │
                │  • Port: 5432                │
                └──────────────┬──────────────┘
                               │
                ┌──────────────▼──────────────┐
                │        NAMED VOLUME          │
                │    grade-tracker-db-data     │
                │  • Data persists on restart  │
                └─────────────────────────────┘


          


## Table of Contents

* [Project Overview](#Project-Overview)
* [Architecture](#architecture)
* [Technology Stack](#technology-stack)
* [Project Structure](#project-structure)
* [Services](#services)
* [Prerequisites](#prerequisites)
* [Environment Configuration](#environment-configuration)
* [Running the Application](#running-the-application)
* [Using the Application](#using-the-application)
* [Docker Images](#docker-images)
* [Building Images](#building-images)
* [Health Checks](#health-checks)
* [Database Initialization](#database-initialization)
* [Data Persistence](#data-persistence)
* [Security](#security)
* [Useful Docker Commands](#useful-docker-commands)
* [Troubleshooting](#troubleshooting)
* [Stopping and Cleaning Up](#stopping-and-cleaning-up)
* [Development Workflow](#development-workflow)
* [Project Requirements](#project-requirements)
* [Author](#author)

---

## Project Overview

The **Student Grade Tracker** is a three-tier web application consisting of:

1. **Frontend** — Nginx serving the web interface.
2. **Backend** — Node.js/Express REST API.
3. **Database** — PostgreSQL for persistent storage.

The application allows users to:

* View students
* Add students
* Record grades
* View grade information
* View statistics
* Store data persistently in PostgreSQL

The entire application runs as separate Docker containers connected through a dedicated Docker network.

---


### Communication Flow

```text
Browser
   |
   v
Nginx Frontend
   |
   | /api/
   v
Node.js Backend
   |
   v
PostgreSQL Database
```

The backend and database communicate internally through the Docker network. The PostgreSQL service is not exposed directly to the host.

---

## Technology Stack

| Component         | Technology            |
| ----------------- | --------------------- |
| Frontend          | HTML, CSS, JavaScript |
| Web Server        | Nginx                 |
| Backend           | Node.js               |
| API Framework     | Express.js            |
| Database          | PostgreSQL            |
| Containerization  | Docker                |
| Orchestration     | Docker Compose        |
| Container Network | Docker Bridge Network |
| Persistence       | Docker Named Volume   |
| Security Scanning | Trivy                 |
| Version Control   | Git/GitHub            |
| Image Registry    | Docker Hub            |

---

## Project Structure

```text
student-grade-tracker/
│
├── frontend/
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── nginx.conf
│   └── src/
│       └── index.html
│
├── backend/
│   ├── Dockerfile
│   ├── .dockerignore
│   ├── package.json
│   └── src/
│       └── server.js
│
├── database/
│   └── init.sql
│
├── scripts/
│   ├── build.sh
│   └── healthcheck.sh
│
├── docs/
│   └── architecture.md
│
├── docker-compose.yml
├── .env.example
├── .gitignore
├── README.md
└── SUBMISSION_CHECKLIST.md
```

---

## Services

### Frontend

The frontend is served using Nginx.

**Responsibilities:**

* Serve the web interface
* Provide the user interface for managing students and grades
* Forward `/api/` requests to the backend
* Provide a health endpoint

Container port:

```text
8080
```

---

### Backend

The backend is a Node.js application using Express.

**Responsibilities:**

* Provide REST API endpoints
* Manage students
* Manage grades
* Calculate statistics
* Communicate with PostgreSQL
* Provide a `/health` endpoint

Container port:

```text
3000
```

---

### Database

The database uses PostgreSQL.

**Responsibilities:**

* Store students
* Store grades
* Provide persistent application data
* Initialize the database using `database/init.sql`

Container port:

```text
5432
```

---

## Prerequisites

Install the following before running the project:

* Docker
* Docker Compose
* Git

Verify Docker:

```bash
docker --version
```

Verify Docker Compose:

```bash
docker compose version
```

Verify Git:

```bash
git --version
```

Optional security scanner:

```bash
trivy --version
```

---

## Environment Configuration

The project uses environment variables for configuration.

Copy the example file:

```bash
cp .env.example .env
```

Edit it:

```bash
nano .env
```

Example:

```env
APP_VERSION=1.0.0

POSTGRES_DB=grades_db
POSTGRES_USER=grade_user
POSTGRES_PASSWORD=YourStrongPassword

FRONTEND_PORT=8080

DOCKERHUB_USERNAME=kenanricky
```

### Important

The `.env` file contains sensitive information and **must not be committed to Git**.

The `.gitignore` file excludes `.env`.

Use `.env.example` when sharing configuration requirements.

---

## Running the Application

### 1. Clone the repository

```bash
git clone https://github.com/KenanRicky/docker-on-student-grade-tracker.git
```

Enter the project:

```bash
cd docker-on-student-grade-tracker
```

### 2. Create the environment file

```bash
cp .env.example .env
```

Update the values as required.

### 3. Build the images

```bash
docker compose build
```

### 4. Start the application

```bash
docker compose up -d
```

### 5. Check the containers

```bash
docker compose ps
```

The frontend, backend, and database should become healthy.

### 6. Open the application

Open:

```text
http://localhost:8080
```

---

## Using the Application

Once the application is running, the frontend provides functionality for managing student records and grades.

Typical workflow:

1. Open the application in a browser.
2. View the existing students.
3. Add a new student.
4. Record a grade.
5. View updated grade information.
6. View statistics.
7. Restart the containers and verify that the data remains available.

---

## Docker Images

The custom application images are published on Docker Hub.

### Frontend

```text
kenanricky/grade-tracker-frontend:v1.0.0
```

### Backend

```text
kenanricky/grade-tracker-backend:v1.0.0
```

Pull the frontend:

```bash
docker pull kenanricky/grade-tracker-frontend:v1.0.0
```

Pull the backend:

```bash
docker pull kenanricky/grade-tracker-backend:v1.0.0
```

---

## Building Images

### Build the frontend

```bash
docker build \
  -t grade-tracker-frontend:v1.0.0 \
  ./frontend
```

### Build the backend

```bash
docker build \
  -t grade-tracker-backend:v1.0.0 \
  ./backend
```

### List images

```bash
docker images
```

---

## Automated Build Script

The project includes:

```text
scripts/build.sh
```

Make it executable:

```bash
chmod +x scripts/build.sh
```

Run:

```bash
./scripts/build.sh
```

Specify a version:

```bash
./scripts/build.sh 1.0.1
```

The script builds the frontend and backend images and returns a non-zero exit code if a build fails.

---

## Health Checks

All three services have Docker health checks.

Check service status:

```bash
docker compose ps
```

Run the project health-check script:

```bash
./scripts/healthcheck.sh
```

Expected result:

```text
============================================
 Health Check Summary
============================================
Passed: 3
Failed: 0

✓ ALL HEALTH CHECKS PASSED
```

You can also inspect container health directly:

```bash
docker inspect \
  --format='{{.State.Health.Status}}' \
  grade-tracker-backend
```

---

## Database Initialization

PostgreSQL uses the official PostgreSQL Docker image.

The project mounts:

```text
database/init.sql
```

into:

```text
/docker-entrypoint-initdb.d/init.sql
```

Docker Compose configuration:

```yaml
volumes:
  - ./database/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
```

The PostgreSQL image executes initialization scripts in `/docker-entrypoint-initdb.d/` when the database data directory is initialized for the first time.

### Important

The initialization script does **not** execute every time the container starts.

It runs when PostgreSQL initializes an empty data directory.

To test initialization from a completely clean database:

```bash
docker compose down -v
docker compose up -d
```

Then check:

```bash
docker compose logs database
```

You can also inspect the tables:

```bash
docker compose exec database \
psql -U grade_user -d grades_db -c "\dt"
```

---

## Data Persistence

PostgreSQL uses a named Docker volume:

```text
student-grade-tracker-postgres-data
```

Check volumes:

```bash
docker volume ls
```

The database data remains available when containers are stopped and recreated.

Test persistence:

```bash
docker compose down
docker compose up -d
```

The database data should still exist.

To completely remove the database volume:

```bash
docker compose down -v
```

**Warning:** removing the volume deletes the PostgreSQL data stored in it.

---

## Security

The project applies several Docker security practices.

### Non-root containers

The backend runs as the Node.js non-root user.

The frontend uses an unprivileged Nginx image.

### Environment variables

Database credentials are supplied through environment variables instead of being hard-coded into application source code.

### `.env` protection

The `.env` file is excluded from Git.

Never commit:

```text
.env
```

to GitHub.

### Read-only initialization file

The database initialization script is mounted read-only:

```yaml
./database/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
```

### Vulnerability scanning

Custom images can be scanned using Trivy:

```bash
trivy image grade-tracker-frontend:v1.0.0
```

```bash
trivy image grade-tracker-backend:v1.0.0
```

Review CRITICAL vulnerabilities before deployment.

---

## Useful Docker Commands

### Show running containers

```bash
docker ps
```

### Show all containers

```bash
docker ps -a
```

### Show Compose services

```bash
docker compose ps
```

### View all logs

```bash
docker compose logs
```

### Follow logs

```bash
docker compose logs -f
```

### View backend logs

```bash
docker compose logs -f backend
```

### View frontend logs

```bash
docker compose logs -f frontend
```

### View database logs

```bash
docker compose logs -f database
```

### Stop the application

```bash
docker compose stop
```

### Start the application

```bash
docker compose start
```

### Restart the application

```bash
docker compose restart
```

### Rebuild images

```bash
docker compose build --no-cache
```

### Rebuild and start

```bash
docker compose up -d --build
```

---

## Troubleshooting

### Check service status

```bash
docker compose ps
```

### Check logs

```bash
docker compose logs backend
```

or:

```bash
docker compose logs database
```

### Check backend health

```bash
docker compose exec backend \
wget --spider http://localhost:3000/health
```

### Check frontend health

```bash
docker compose exec frontend \
wget --spider http://localhost:8080/health
```

### Check database readiness

```bash
docker compose exec database \
pg_isready -U grade_user -d grades_db
```

### Recreate the entire environment

If you need to start from a completely clean environment:

```bash
docker compose down -v
docker compose up -d --build
```

**Warning:** `-v` removes the PostgreSQL data volume.

---

## Stopping and Cleaning Up

Stop containers:

```bash
docker compose down
```

Stop containers and remove the database volume:

```bash
docker compose down -v
```

Remove unused Docker resources:

```bash
docker system prune
```

Use the prune command carefully because it removes unused Docker resources.

---

## Development Workflow

A typical development workflow is:

```bash
# Check repository
git status

# Build images
docker compose build

# Start application
docker compose up -d

# Check services
docker compose ps

# Run health checks
./scripts/healthcheck.sh

# View logs
docker compose logs -f

# Stop application
docker compose down
```

After making changes:

```bash
docker compose up -d --build
```

Then verify:

```bash
docker compose ps
```

---

## Git Workflow

Check changes:

```bash
git status
```

Add all files:

```bash
git add .
```

Commit:

```bash
git commit -m "feat: update student grade tracker"
```

Push:

```bash
git push
```

### Important

Before committing, verify that `.env` is not included:

```bash
git status
```

---

## Project Requirements

This project demonstrates:

* Three-service container architecture
* Custom Dockerfiles
* Multi-stage Docker build
* Non-root containers
* Docker health checks
* Specific image version tags
* `.dockerignore` files
* Docker Compose orchestration
* Named Docker network
* Named PostgreSQL volume
* PostgreSQL initialization
* Health-based service dependencies
* Restart policies
* Environment-based configuration
* Docker image vulnerability scanning
* Automated build and health-check scripts
* Docker Hub image publishing
* Git/GitHub version control
* Project documentation

---

## Repository

GitHub:

```text
https://github.com/KenanRicky/docker-on-student-grade-tracker
```

Docker Hub:

```
https://hub.docker.com/repositories/kenanricky
```

---

## Evidences

![alt text](<Screenshot from 2026-09-21 18-00-05-1.png>)

![alt text](<Screenshot from 2026-09-21 18-12-04.png>)

![alt text](<Screenshot from 2026-09-21 17-59-08.png>)

## Author

**Ricky Abura**

Student Grade Tracker — Dockerised Web Application Stack

Built as an independent Docker and Docker Compose project.




