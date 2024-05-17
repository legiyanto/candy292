#!/bin/bash

# Meminta pengguna untuk memasukkan password root MySQL
read -sp "Masukkan password root MySQL: " root_password
echo

# Membuat database candy dan mengimpor file SQL
mysql -u root -p"$root_password" <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS candy;
USE candy;
SOURCE /home/otomasi/candy.sql;
MYSQL_SCRIPT

echo "Database candy telah dibuat dan file candy.sql telah diimpor."
