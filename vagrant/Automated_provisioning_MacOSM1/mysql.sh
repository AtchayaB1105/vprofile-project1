#!/bin/bash

DBPASS="admin123"

######################################
# Add MariaDB 10.5 Repo for AL2023
######################################
sudo tee /etc/yum.repos.d/MariaDB.repo > /dev/null <<EOF
[mariadb]
name=MariaDB
baseurl=https://downloads.mariadb.com/MariaDB/mariadb-10.5/yum/rhel/9/x86_64/
gpgcheck=0
enabled=1
module_hotfixes=1
EOF

######################################
# Install packages
######################################
sudo dnf update -y
sudo dnf install git zip unzip -y
sudo dnf install MariaDB-server MariaDB-client -y
sudo dnf install mariadb105-server -y

######################################
# Start MariaDB
######################################
sudo systemctl start mariadb
sudo systemctl enable mariadb

######################################
# Set root password
######################################
mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '$DBPASS';
FLUSH PRIVILEGES;
EOF

######################################
# Clone project
######################################
cd /tmp
git clone -b local https://github.com/AtchayaB1105/vprofile-project1.git

######################################
# Create DB and user
######################################
mysql -u root -p"$DBPASS" <<EOF
CREATE DATABASE accounts;
GRANT ALL PRIVILEGES ON accounts.* TO 'admin'@'localhost' IDENTIFIED BY 'admin123';
FLUSH PRIVILEGES;
EOF

######################################
# Import backup
######################################
mysql -u root -p"$DBPASS" accounts < /tmp/vprofile-project1/src/main/resources/db_backup.sql

######################################
# Final flush
######################################
mysql -u root -p"$DBPASS" -e "FLUSH PRIVILEGES;"
