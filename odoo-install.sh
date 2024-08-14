#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y git wget python3-pip build-essential python3-dev libxml2-dev libxslt1-dev zlib1g-dev libsasl2-dev libldap2-dev libjpeg-dev libpq-dev libjpeg8-dev liblcms2-dev libblas-dev libatlas-base-dev libssl-dev libffi-dev libreadline-dev libsqlite3-dev libbz2-dev libncurses5-dev libncursesw5-dev xz-utils libyaml-dev libgdbm-dev libdb5.3-dev libbz2-dev libc6-dev libexpat1-dev tk-dev libmpdec-dev libbluetooth-dev libgpm-dev

# Install PostgreSQL
sudo apt install -y postgresql

# Create PostgreSQL user for Odoo
sudo su - postgres -c "createuser --createdb --username postgres --no-createrole --no-superuser --no-password odoo14"

# Clone Odoo source code
sudo mkdir /odoo
sudo git clone https://www.github.com/odoo/odoo --depth 1 --branch 14.0 --single-branch /odoo/odoo-server/

# Install Python dependencies
sudo pip3 install -r /odoo/odoo-server/requirements.txt

# Create Odoo system user
sudo adduser --system --home=/odoo/ --group odoo

# Create and configure Odoo configuration file
sudo tee /etc/odoo.conf > /dev/null <<EOL
[options]
   admin_passwd = admin
   db_host = False
   db_port = False
   db_user = odoo14
   db_password = False
   addons_path = /odoo/odoo-server/addons
   logfile = /var/log/odoo/odoo.log
EOL

# Change ownership of the configuration file
sudo chown odoo: /etc/odoo.conf

# Create systemd service file for Odoo
sudo tee /etc/systemd/system/odoo.service > /dev/null <<EOL
[Unit]
Description=Odoo
Documentation=http://www.odoo.com
[Service]
Type=simple
User=odoo
ExecStart=/odoo/odoo-server/odoo-bin -c /etc/odoo.conf
[Install]
WantedBy=default.target
EOL

# Start and enable Odoo service
sudo systemctl daemon-reload
sudo systemctl start odoo
sudo systemctl enable odoo

echo "Odoo installation is complete. Access it via http://your_server_ip:8069"
