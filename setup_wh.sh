#!/bin/bash

sudo dnf install -y nginx python3

sudo python3 -m pip install flask

mkdir -p /opt/webhook
cd /opt/webhook

API_KEY="tentenhahaha"

cat << EOF > /opt/webhook/webhook.py
from flask import Flask, request, abort
import os

app = Flask(__name__)

API_KEY = '$API_KEY'

@app.route('/webhook', methods=['POST'])
def webhook():
    if request.headers.get('x-api-key') == API_KEY:
        os.system('sudo reboot')
        return 'Rebooting...', 200
    else:
        abort(403)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
EOF

cat << EOF > /etc/nginx/conf.d/webhook.conf
server {
    listen 80;
    server_name _;

    location /webhook {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
    }
}
EOF

sudo systemctl start nginx
sudo systemctl enable nginx

cat << EOF > /etc/systemd/system/webhook.service
[Unit]
Description=Flask Webhook Service
After=network.target

[Service]
ExecStart=/usr/bin/python3 /opt/webhook/webhook.py
Restart=always
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start webhook
sudo systemctl enable webhook

echo 'root ALL=(ALL) NOPASSWD: /sbin/reboot' | sudo tee -a /etc/sudoers

echo "Setup completed. Your webhook is now ready."
