#!/bin/sh
set -e

echo "[entrypoint] Starting codexmanager-service..."
codexmanager-service &
SERVICE_PID=$!

echo "[entrypoint] Starting codexmanager-web..."
codexmanager-web &
WEB_PID=$!

trap 'echo "[entrypoint] Shutting down..."; kill "$SERVICE_PID" "$WEB_PID" 2>/dev/null; wait; exit 0' TERM INT

while true; do
    if ! kill -0 "$SERVICE_PID" 2>/dev/null; then
        echo "[entrypoint] codexmanager-service exited unexpectedly"
        kill "$WEB_PID" 2>/dev/null || true
        exit 1
    fi
    if ! kill -0 "$WEB_PID" 2>/dev/null; then
        echo "[entrypoint] codexmanager-web exited unexpectedly"
        kill "$SERVICE_PID" 2>/dev/null || true
        exit 1
    fi
    sleep 5
done
