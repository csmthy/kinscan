#!/bin/zsh
# Starts KinScan and opens the dashboard. If an up-to-date copy is already running, just opens it;
# if an older copy is running, stops it and starts the new one.
cd "${0:A:h}" || exit 1
url=http://127.0.0.1:8765

pid=$(lsof -nP -tiTCP:8765 -sTCP:LISTEN 2>/dev/null | head -1)
if [[ -n "$pid" ]]; then
  if ! ps -o command= -p "$pid" | grep -q "kintara_tracker.py"; then
    echo "Port 8765 is used by another program, so KinScan can't start."
    read '?Press Enter to close.'
    exit 1
  fi
  if curl -fs -m 5 -o /dev/null "$url/api/freshness"; then
    open "$url"
    exit 0
  fi
  echo "Stopping the older KinScan that's running..."
  kill "$pid" 2>/dev/null
  for i in {1..20}; do lsof -nP -tiTCP:8765 -sTCP:LISTEN >/dev/null 2>&1 || break; sleep 0.5; done
fi

echo "Starting KinScan at $url. Close this window to stop it."
python3 kintara_tracker.py
read '?Press Enter to close.'
