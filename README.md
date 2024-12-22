# Setup mailwizz with docker compose

1. Copy all the files in this repo inside a folder named `mailwizz` in your server.
2. `cd mailwizz`
3. Replace `MYSQL_ROOT_PASSWORD` and `MYSQL_PASSWORD` in `docker-compose.yml` with your own passwords.
4. `docker compose build`
5. `docker compose up -d`
6. Navigate to the ip of your server at the page http://xx.xx.xx.xx/install/index.php and follow installation step
   1. `cd web/`
   2. `chmod 0777 apps/common/config/`
   3. `chmod 0777 backend/assets/cache/`
   4. `chmod 0777 customer/assets/cache`
   5. `chmod 0777 frontend/assets/cache`
   6. `chmod 0777 frontend/assets/files`
   7. `chmod 0777 frontend/assets/gallery`
   8. `chmod 0777 apps/extensions`
7. When asked to select the database remember that is running in a different container so you cannot access with localhost, you can use the name of the container: `mailwizz-mysql`
8. Add an A record to cloudflare DNS with the ip of your server then setup cloudflare on settings -> reverse proxy (http://xx.xx.xx.xx/backend/index.php/settings/reverse-proxy)
>>>>>>> e986cc9 (Initial commit)
