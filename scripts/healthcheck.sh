#!/usr/bin/env bash
set -e

FRONTEND_URL="http://localhost:8080"
BACKEND_HEALTH_URL="http://localhost:8080/health"

echo "=== Running Stack Health Checks ==="

# Check Frontend
echo -n "Checking Frontend ($FRONTEND_URL)... "
if curl -s -f -o /dev/null "$FRONTEND_URL"; then
    echo "PASS"
else
    echo "FAIL"
    exit 1
fi

# Check Backend Health Endpoint via Proxy
echo -n "Checking Backend Health ($BACKEND_HEALTH_URL)... "
HEALTH_RESP=$(curl -s "$BACKEND_HEALTH_URL" || true)
if [[ "$HEALTH_RESP" == *"OK"* ]]; then
    echo "PASS"
else
    echo "FAIL: $HEALTH_RESP"
    exit 1
fi

echo "=== All Health Checks Passed! ==="