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