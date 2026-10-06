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




# Architecture & Technical Documentation

## 1. System Architecture
The Student Grade Tracker is architected as a standard decoupled 3-tier cloud native application:
- **Presentation Layer (Frontend):** Static assets served via Nginx containers, containerized for high-speed edge distribution and decoupled from backend code.
- **Application Logic Layer (Backend):** Node.js Express REST API handling business logic, student records, grading rules, and database queries.
- **Data Persistence Layer (Database):** PostgreSQL running as a StatefulSet to maintain predictable network identifiers (`postgres-0`) and stateful storage mapping.

## 2. Kubernetes Resource Design Rationale
- **StatefulSet vs Deployment for Database:** Databases require consistent storage attachment and ordered pod scaling/termination. A `StatefulSet` guarantees dedicated PVC binding per pod ordinal.
- **ConfigMaps:** Decouples configuration (database host, ports, application environment) from container image layers, permitting environment promotion without container rebuilds.
- **Init Containers:** The backend deployment utilizes a lightweight `busybox` init container to poll the database TCP port (`postgres-service:5432`), preventing race conditions where the API boots before PostgreSQL is ready to accept connections.

## 3. ReplicaSet Exercise Observations
During Step 4, deploying the backend via a raw `ReplicaSet` demonstrated:
- **Self-Healing:** Deleting a pod instance immediately triggered the ReplicaSet controller to spin up a replacement pod.
- **Immutability Limitations:** Updating container image tags directly in the ReplicaSet template did not propagate updates to running pods, highlighting why higher-level abstractions like `Deployments` with `RollingUpdate` strategies are required for production CI/CD lifecycles.

![alt text](<Screenshot from 2026-10-04 20-37-43.png>)

## 4. Data Persistence & Verification
Persistence was successfully validated by:
1. Creating test student profiles and recording grades through the UI.
2. Forcibly deleting the database pod (`kubectl delete pod postgres-0 -n grade-tracker`).
3. Observing Kubernetes automatically recreate `postgres-0` via the StatefulSet controller.
4. Verifying via UI browser refresh that all prior students and grade records persisted cleanly through the bound PVC and `hostPath` storage.


