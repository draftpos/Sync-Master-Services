#!/bin/bash

# Ask for site name
read -p "Enter the site name (e.g., labmaster.local): " SITE

# Names
SERVICE_NAME="saas-${SITE}.service"
TIMER_NAME="saas-${SITE}.timer"

# Paths
BENCH_PATH="$HOME/Documents/frappe-bench"
BENCH_BIN="$BENCH_PATH/env/bin/bench"
RUN_USER="$(whoami)"

echo "Creating systemd service for site: $SITE"

# Create systemd service
sudo tee /etc/systemd/system/$SERVICE_NAME > /dev/null <<EOF
[Unit]
Description=Frappe SASS Client Sync for $SITE
After=network.target

[Service]
Type=oneshot
User=$RUN_USER
WorkingDirectory=$BENCH_PATH
ExecStart=$BENCH_BIN --site $SITE execute sass_client.utils.client_sync.sync_to_main_app
EOF

# Create systemd timer
sudo tee /etc/systemd/system/$TIMER_NAME > /dev/null <<EOF
[Unit]
Description=Run SASS Client Sync for $SITE every 1 minute

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
Persistent=true
Unit=$SERVICE_NAME

[Install]
WantedBy=timers.target
EOF

# Reload systemd and start timer
sudo systemctl daemon-reload
sudo systemctl enable --now $TIMER_NAME

echo "✅ SASS Client sync scheduled successfully!"
echo "Service: $SERVICE_NAME"
echo "Timer:   $TIMER_NAME"
