#!/bin/bash

APP_DIR="/opt/app"

# Make the ubuntu user owner of all files under the application directory
sudo chown -R ubuntu:ubuntu $APP_DIR

# Update the package list and install dependencies
sudo apt update
sudo apt install -y python3-pip python3-venv postgresql postgresql-contrib nginx 

# Initialize and start PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Set up PostgreSQL database
source $APP_DIR/secrets.sh

# Switch to the postgres user and create a new database and user
sudo -i -u postgres psql <<EOF
CREATE DATABASE mvp;
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';
ALTER ROLE $DB_USER SET client_encoding TO 'utf8';
ALTER ROLE $DB_USER SET default_transaction_isolation TO 'read committed';
ALTER ROLE $DB_USER SET timezone TO 'UTC';
GRANT ALL PRIVILEGES ON DATABASE mvp TO $DB_USER;
EOF

sed -i "s/REPLACE_SECRET_KEY/$SECRET_KEY/g" $APP_DIR/cloudtalents/settings.py
sed -i "s/REPLACE_DATABASE_USER/$DB_USER/g" $APP_DIR/cloudtalents/settings.py
sed -i "s/REPLACE_DATABASE_PASSWORD/$DB_PASSWORD/g" $APP_DIR/cloudtalents/settings.py

# Create a Python virtual environment
python3 -m venv venv
source venv/bin/activate

# Install Python dependencies
pip install --upgrade pip
pip install -r $APP_DIR/requirements.txt

# Apply Django migrations
python3 $APP_DIR/manage.py makemigrations
python3 $APP_DIR/manage.py migrate

# Set up Gunicorn to serve the Django application
cat > /tmp/gunicorn.service <<EOF
[Unit]
Description=gunicorn daemon
After=network.target

[Service]
User=$USER
Group=www-data
WorkingDirectory=$APP_DIR
ExecStart=$PWD/venv/bin/gunicorn \
          --workers 3 \
          --bind unix:/tmp/gunicorn.sock \
          cloudtalents.wsgi:application

[Install]
WantedBy=multi-user.target
EOF
sudo mv /tmp/gunicorn.service /etc/systemd/system/gunicorn.service

# Start and enable Gunicorn service
sudo systemctl start gunicorn
sudo systemctl enable gunicorn

# Configure Nginx to proxy requests to Gunicorn
sudo rm /etc/nginx/sites-enabled/default
cat > /tmp/nginx_config <<EOF
server {
    listen 80;
    server_name your_domain_or_IP;

    location = /favicon.ico { access_log off; log_not_found off; }

    location /media/ {
        root $APP_DIR/;
    }

    location / {
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto \$scheme;
        proxy_pass http://unix:/tmp/gunicorn.sock;
    }
}
EOF
sudo mv /tmp/nginx_config /etc/nginx/sites-available/cloudtalents

# Enable the Nginx configuration
sudo ln -s /etc/nginx/sites-available/cloudtalents /etc/nginx/sites-enabled

# Test Nginx configuration and restart Nginx
sudo nginx -t
sudo systemctl restart nginx

# Allow traffic on port 80
sudo ufw allow 'Nginx Full'

# Print completion message
echo "Django application setup complete!"