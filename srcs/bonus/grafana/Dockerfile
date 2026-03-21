FROM debian:12

RUN apt-get update && apt-get install -y apt-transport-https wget gnupg

RUN mkdir -p /etc/apt/keyrings \
	&& wget -O /etc/apt/keyrings/grafana.asc https://apt.grafana.com/gpg-full.key \
 	&& chmod 644 /etc/apt/keyrings/grafana.asc

RUN echo "deb [signed-by=/etc/apt/keyrings/grafana.asc] https://apt.grafana.com stable main" \
	| tee -a /etc/apt/sources.list.d/grafana.list

RUN apt-get update && apt-get install -y grafana


EXPOSE 3000

CMD ["/usr/share/grafana/bin/grafana", "server", \
    "--config=/etc/grafana/grafana.ini", \
    "--homepath=/usr/share/grafana"]
