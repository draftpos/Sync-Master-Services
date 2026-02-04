#!/bin/bash

# Ask for site name
read -p "🌐 Enter the site name for sales sync (e.g., labmaster.local): " SITE

# Derived names for sales
SERVICE_NAME="sales-sync-${SITE}.service"
TIMER_NAME="sales-sync-${SITE}.timer"

# Paths
BENCH_PATH="/home/frappe/frappe-bench"
PYTHON_BENCH="/home/frappe/frappe-env/bin/bench"

# Create systemd service file
sudo tee /etc/systemd/system/$SERVICE_NAME > /dev/null <<EOF
[Unit]
Description=Frappe Sales Sync Job for $SITE
After=network.target

[Service]
Type=oneshot
User=frappe
WorkingDirectory=$BENCH_PATH
ExecStart=$PYTHON_BENCH --site $SITE execute sync_master.sync_master.api.push_pending_invoices
EOF

# Create systemd timer file
sudo tee /etc/systemd/system/$TIMER_NAME > /dev/null <<EOF
[Unit]
Description=Run Frappe Sales Sync for $SITE every 5 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=5min
Persistent=true

[Install]
WantedBy=timers.target
EOF

# Reload systemd, enable and start timer
sudo systemctl daemon-reload
sudo systemctl enable --now $TIMER_NAME
sudo systemctl restart $TIMER_NAME

# Output success info
echo "✅ Sales sync service and timer created for site: $SITE"
echo "Service: $SERVICE_NAME"
echo "Timer: $TIMER_NAME"
