#!/bin/bash
# User Data Script for Backend Server (Laravel)

LOGFILE="/var/log/user-data.log"
exec > >(tee -a ${LOGFILE}) 2>&1

echo "===== Backend Setup Started at $(date) ====="

# Update system
export DEBIAN_FRONTEND=noninteractive
export COMPOSER_ALLOW_SUPERUSER=1
export HOME=/root

# Update system
apt-get update -y

# Install essential packages
echo "Installing packages..."
apt-get install -y software-properties-common
add-apt-repository -y ppa:ondrej/php
apt-get update -y

apt-get install -y \
    nginx \
    php8.2-fpm \
    php8.2-cli \
    php8.2-mysql \
    php8.2-mbstring \
    php8.2-xml \
    git \
    curl \
    unzip

# Install Composer
echo "Installing Composer..."
curl -sS https://getcomposer.org/installer -o /tmp/composer-setup.php
HASH=`curl -sS https://composer.github.io/installer.sig`
echo $HASH
php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') === '$HASH') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
sudo php /tmp/composer-setup.php --install-dir=/usr/local/bin --filename=composer
# Verify Composer is installed
export COMPOSER_ALLOW_SUPERUSER=1
composer || {
    echo "ERROR: Composer installation failed!"
    exit 1
}

# Configure Nginx
cat > /etc/nginx/sites-available/default <<'EOF'
server {
    listen 80 default_server;
    root /var/www/html/public;
    index index.php index.html;
    server_name _;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        include snippets/fastcgi-php.conf;
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
    }
}
EOF

systemctl enable nginx
systemctl restart nginx

# Deploy Laravel
echo "Deploying Laravel..."
rm -rf /var/www/html
cd /var/www
git clone https://github.com/OmarZakaria10/laravel-Obelion-task.git html
cd html

echo "Installing Composer dependencies..."
composer install --no-interaction --no-dev || {
    echo "Composer install failed, retrying..."
    composer install --no-interaction
}

# Create basic .env (will be updated by CI/CD with real DB credentials)
cp .env.example .env
php artisan key:generate --force

mkdir -p storage/framework/{sessions,views,cache} storage/logs bootstrap/cache
chown -R www-data:www-data /var/www/html
chmod -R 775 storage bootstrap/cache

systemctl restart php8.2-fpm nginx
sleep 2

echo "===== Backend Setup Completed at $(date) ====="
if [ -d "/var/www/html" ]; then
    cd /var/www/html
    php artisan --version 2>/dev/null && echo "✅ Laravel deployed successfully" || echo "⚠️ Laravel needs configuration"
fi
