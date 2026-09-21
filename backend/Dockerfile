# Stage 1: Build & dependency resolution
FROM node:18-alpine AS builder
WORKDIR /usr/src/app

COPY package*.json ./
# Install production dependencies only
RUN npm ci --omit=dev

# Stage 2: Final lean runtime image
FROM node:18-alpine
WORKDIR /usr/src/app

# Install wget for HEALTHCHECK
RUN apk add --no-cache wget

# Copy installed node_modules and application code
COPY --from=builder /usr/src/app/node_modules ./node_modules
COPY package*.json ./
COPY src/ ./src/

# Use built-in node user (non-root)
USER node

EXPOSE 3000

HEALTHCHECK --interval=10s --timeout=5s --start-period=15s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1

CMD ["npm", "start"]