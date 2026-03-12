FROM debian:12

# RUN apt update && \
#     apt install -y debian-keyring debian-archive-keyring apt-transport-https curl gnupg

# RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
#   | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

# RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
#   | tee /etc/apt/sources.list.d/caddy-stable.list

# RUN apt update && apt install -y caddy

# COPY Caddyfile /etc/caddy/Caddyfile
# COPY site /srv

# EXPOSE 80

# sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https curl
# curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
# curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
# sudo chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg
# sudo chmod o+r /etc/apt/sources.list.d/caddy-stable.list
# sudo apt update
# sudo apt install caddy

RUN apt update


RUN apt install -y debian-keyring \
		debian-archive-keyring \
		apt-transport-https \
		curl && apt clean

RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' \
		| gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg

RUN curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' \
		| tee /etc/apt/sources.list.d/caddy-stable.list

RUN chmod o+r /usr/share/keyrings/caddy-stable-archive-keyring.gpg

RUN chmod o+r /etc/apt/sources.list.d/caddy-stable.list

RUN apt update && apt install caddy

RUN mkdir -p /var/www/html && chmod 777 /var/www/html

EXPOSE 80

CMD ["caddy", "run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]