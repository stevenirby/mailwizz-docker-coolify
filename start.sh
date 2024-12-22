#!/bin/bash

# Start cron in the background
service cron start

# Add MailWizz cron jobs
cat <<EOF > /etc/cron.d/mwcron
# Campaigns sender, runs each minute.
* * * * * /usr/bin/php -q /var/www/web/apps/console/console.php send-campaigns >/dev/null 2>&1

# Queue handler, runs each minute.
* * * * * /usr/bin/php -q /var/www/web/apps/console/console.php queue >/dev/null 2>&1

# Transactional email sender, runs once at 2 minutes.
*/2 * * * * /usr/bin/php -q /var/www/web/apps/console/console.php send-transactional-emails >/dev/null 2>&1

# Bounce handler, runs once at 10 minutes.
*/10 * * * * /usr/bin/php -q /var/www/web/apps/console/console.php bounce-handler >/dev/null 2>&1

# Feedback loop handler, runs once at 20 minutes.
*/20 * * * * /usr/bin/php -q /var/www/web/apps/console/console.php feedback-loop-handler >/dev/null 2>&1

# Delivery/Bounce processor, runs once at 3 minutes.
*/3 * * * * /usr/bin/php -q /var/www/web/apps/console/console.php process-delivery-and-bounce-log >/dev/null 2>&1

# Various tasks, runs each hour.
0 * * * * /usr/bin/php -q /var/www/web/apps/console/console.php hourly >/dev/null 2>&1

# Daily cleaner, runs once a day.
0 0 * * * /usr/bin/php -q /var/www/web/apps/console/console.php daily >/dev/null 2>&1
EOF

# Ensure proper permissions for the cron job file
chmod 0644 /etc/cron.d/mwcron
crontab /etc/cron.d/mwcron
chown -R www-data:www-data /var/www/web/apps/common/runtime
chmod -R 775 /var/www/web/apps/common/runtime

# Install and configure nginx
apt-get update && apt-get install -y nginx

# Configure nginx
cat > /etc/nginx/sites-available/default << 'EOF'
server {
    listen 80;

    # max upload
    client_max_body_size 108M;

    # keep utf-8
    charset UTF-8;

    # http://serverfault.com/questions/269420/disable-caching-when-serving-static-files-with-nginx-for-development
    sendfile  off;

    access_log /var/log/nginx/access.log;

    root /var/www/web;
    index index.php;

    location / {
         if (!-e $request_filename){
            rewrite ^(/)?api/.*$ /api/index.php;
         }
         if (!-e $request_filename){
            rewrite ^(/)?customer/.*$ /customer/index.php;
         }
         if (!-e $request_filename){
            rewrite ^(/)?backend/.*$ /backend/index.php;
         }
         if (!-e $request_filename){
            rewrite ^(.*)$ /index.php;
         }
         index  index.html index.htm index.php;
     }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        fastcgi_param PHP_VALUE "error_log=/var/log/nginx/php_errors.log";
        fastcgi_buffers 16 16k;
        fastcgi_buffer_size 32k;
        include fastcgi_params;
    }
}
EOF

# Configure PHP-FPM to listen only on port 9000
sed -i 's|listen = /run/php/php8.3-fpm.sock|listen = 127.0.0.1:9000|' /etc/php/8.3/fpm/pool.d/www.conf

# Create log directory
mkdir -p /var/log/nginx

# Start nginx in the background
service nginx start

# Start PHP-FPM
exec /usr/sbin/php-fpm8.3
