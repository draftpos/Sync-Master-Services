#!/bin/bash

echo "🌐 Enter the site name for cloud sync (e.g., labmaster.local):"
read SITE

SERVICE_NAME="cloud-sync-${SITE}.service"
TIMER_NAME="cloud-sync-${SITE}.timer"

BENCH_PATH="/home/frappe/frappe-bench"
PYTHON_BENCH="/home/frappe/frappe-env/bin/bench"

# Create service file
sudo tee /etc/systemd/system/$SERVICE_NAME > /dev/null <<EOF
[Unit]
Description=Frappe Cloud Sync Job for $SITE
After=network.target

[Service]
Type=oneshot
User=frappe
WorkingDirectory=$BENCH_PATH
ExecStart=$PYTHON_BENCH --site $SITE execute sync_master.sync_master.api.sync_from_remote
EOF

# Create timer file
sudo tee /etc/systemd/system/$TIMER_NAME > /dev/null <<EOF
[Unit]
Description=Run Frappe Cloud Sync for $SITE every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Reload systemd and enable timer
sudo systemctl daemon-reload
sudo systemctl enable --now $TIMER_NAME
sudo systemctl restart $TIMER_NAME

echo "Service and timer for update created for site: $SITE"
echo "Service: $SERVICE_NAME"
echo "Timer: $TIMER_NAME"
