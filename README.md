# Setup mailwizz in docker on Coolify


1. Copy all mailwizz files to the folder named `web`.
2. Push up your changes to github or create a new project in Coolify.
3. Go to the ip of your server at the page http://xx.xx.xx.xx/install/index.php and follow installation step
4. When asked to select the database remember that is running in a different container so you cannot access with localhost, you can use the name of the container: `mailwizz-mysql` no port needed.
5. Go to backend settings and set reverse proxy to true.
6. Log into container via the Coolify terminal and run and run `rm -r install/`
7. Optionally, add an A record to cloudflare DNS with the ip of your server then setup cloudflare on settings -> reverse proxy (http://xx.xx.xx.xx/backend/index.php/settings/reverse-proxy)

