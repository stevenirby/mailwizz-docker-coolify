FROM phpdockerio/php:8.3-fpm
WORKDIR "/var/www/web"

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

# Debugging step: List contents of /var/www/web
RUN ls -la /var/www/web

RUN apt-get update && apt-get -y install cron php8.3-mysql php8.3-imap php8.3-gd

# Setup cronjobs
COPY mwcron /etc/cron.d/mwcron
RUN chmod 0644 /etc/cron.d/mwcron
RUN crontab /etc/cron.d/mwcron

# Create the web directory
RUN mkdir -p /var/www/web
RUN mkdir -p /var/www/web/apps/extensions
# Copy web files and set permissions
COPY ./web /var/www/web

RUN chown -R www-data:www-data /var/www/web
RUN chmod -R 0777 /var/www/web/apps/extensions
RUN chmod -R 755 /var/www/web


COPY start.sh /start.sh
RUN chmod +x /start.sh
CMD ["/start.sh"]
