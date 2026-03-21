FROM debian:12

RUN apt-get update && apt-get install -y \
    curl \
    git \
    golang \
    nodejs \
    npm \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
RUN git clone --depth=1 --branch v10.1.1 https://github.com/amir20/dozzle.git .

RUN npm ci && npm run build
RUN go build -o /usr/local/bin/dozzle .

RUN useradd -r -s /bin/false dozzle

USER dozzle

EXPOSE 8080

CMD ["dozzle"]