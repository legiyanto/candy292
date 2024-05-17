#!/bin/bash
sudo tee /etc/apt/sources.list > /dev/null <<EOL
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-proposed main restricted universe
EOL
sudo apt update
sudo apt install -y wget
sudo apt-get install zip unzip
sudo apt install nginx -y
sudo apt install php7.4-fpm -y
sudo apt install php7.4-common php7.4-zip php7.4-curl php7.4-xml php7.4-xmlrpc php7.4-json php7.4-mysql php7.4-pdo php7.4-gd php7.4-imagick php7.4-ldap php7.4-imap php7.4-mbstring php7.4-intl php7.4-cli php7.4-tidy php7.4-bcmath php7.4-opcache -y
sudo apt install mariadb-server mariadb-client -y
echo -n "Masukkan password root yang akan dibuat : "
read passwordmysql
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '$passwordmysql';"
sudo apt install phpmyadmin -y
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
new_content="server {
        listen 80 default_server;
        listen [::]:80 default_server;

        root /var/www/html;
        index index.php index.html index.htm index.nginx-debian.html;
        server_name _;

        location / {
                try_files \$uri \$uri/ =404;
        }

        location ~ \.php\$ {
                try_files \$fastcgi_script_name =404;
                include fastcgi_params;
                fastcgi_pass unix:/run/php/php7.4-fpm.sock;
                fastcgi_index index.php;
                fastcgi_param DOCUMENT_ROOT \$realpath_root;
                fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        }
		location /panel/pages/word_import/import {
        # Konfigurasi untuk penanganan upload file
        # Sesuaikan dengan kebutuhan keamanan Anda
        try_files $uri $uri/ /panel/pages/word_import/import/index.php?$args;
    }

}"

sudo cp /etc/nginx/sites-available/default /etc/nginx/sites-available/default.bak
echo "$new_content" | sudo tee /etc/nginx/sites-available/default > /dev/null
sudo systemctl restart nginx
PHPINI="/etc/php/7.4/fpm/php.ini"
sed -i 's/^\s*session.auto_start\s*=.*/session.auto_start = 1/' "$PHPINI"
systemctl restart php7.4-fpm
PHPINI="/etc/php/7.4/cli/php.ini"
sed -i 's/^\s*session.auto_start\s*=.*/session.auto_start = 1/' "$PHPINI"
systemctl restart php7.4-fpm
# Nama direktori yang ingin dicari
DIRNAME="otomasi"

# Direktori tujuan untuk menyalin
COPY_DESTINATION="/home"

# File zip yang akan di-unzip
ZIP_FILE="/var/www/html/candy.zip"

# Direktori tujuan untuk unzip
UNZIP_DESTINATION="/var/www/html"

# Cari direktori dan salin ke direktori tujuan
echo "Mencari direktori '$DIRNAME' dan menyalin secara rekursif ke '$COPY_DESTINATION'..."
find / -type d -name "$DIRNAME" -exec cp -r {} "$COPY_DESTINATION" \;

# Periksa apakah operasi penyalinan berhasil
if [ $? -eq 0 ]; then
    echo "Direktori '$DIRNAME' berhasil ditemukan dan disalin ke '$COPY_DESTINATION'."
else
    echo "Gagal menemukan atau menyalin direktori '$DIRNAME'."
    exit 1
fi

# Periksa apakah file zip ada
if [ -f "$ZIP_FILE" ]; then
    echo "Menemukan file '$ZIP_FILE'. Unzipping ke '$UNZIP_DESTINATION'..."
    # Unzip file ke direktori tujuan
    unzip "$ZIP_FILE" -d "$UNZIP_DESTINATION"

    # Periksa apakah operasi unzip berhasil
    if [ $? -eq 0 ]; then
        echo "File '$ZIP_FILE' berhasil di-unzip ke '$UNZIP_DESTINATION'."
    else
        echo "Gagal meng-unzip file '$ZIP_FILE'."
        exit 1
    fi
else
    echo "File '$ZIP_FILE' tidak ditemukan."
    exit 1
fi
sudo chmod +x php.sh
sudo ./php.sh
systemctl restart php7.4-fpm
sudo systemctl restart nginx
sudo chmod +x candy.sh
sudo ./candy.sh
sudo chmod -R 777 /var/www/html



