#!/bin/bash
REPO_DIR="./gitops-demo"
INTERVAL=10

echo "Reconciler started. Watching $REPO_DIR every ${INTERVAL}s..."

while true; do
  cd "$REPO_DIR"
  git pull --quiet origin main 2>/dev/null || true

  echo "[$(date +%H:%M:%S)] Applying manifests..."
  kubectl apply -f apps/nginx/ --dry-run=client 2>&1 | grep -v "unchanged" || true

  sleep $INTERVAL
done
