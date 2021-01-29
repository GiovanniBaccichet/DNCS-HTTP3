FROM ubuntu:18.04 AS builder

WORKDIR /opt

RUN apt-get update && \
    apt-get install -y curl git libpcre3 libpcre3-dev zlib1g zlib1g-dev cargo golang-go build-essential cmake;

RUN curl -O https://nginx.org/download/nginx-1.16.1.tar.gz && \
    tar xvzf nginx-1.16.1.tar.gz && \
    git clone --recursive https://github.com/cloudflare/quiche && \
    cd nginx-1.16.1 && \
    patch -p01 < ../quiche/extras/nginx/nginx-1.16.patch && \
    ./configure                                 \
    --prefix=/etc/nginx                    \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/var/run/nginx.pid \
    --lock-path=/var/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --user=nginx \
    --group=nginx  \
    --build="quiche-$(git --git-dir=../quiche/.git rev-parse --short HEAD)" \
    --with-http_ssl_module                  \
    --with-http_v2_module                   \
    --with-http_v3_module                   \
    --with-openssl=../quiche/deps/boringssl \
    --with-quiche=../quiche && \
    make && \
    make install;

FROM ubuntu:18.04

COPY --from=builder /usr/sbin/nginx /usr/sbin/
COPY --from=builder /etc/nginx/ /etc/nginx/

RUN groupadd  nginx \
    && useradd -m -d  /var/cache/nginx -s /sbin/nologin -g nginx nginx \
    && mkdir -p /var/log/nginx \
    && touch /var/log/nginx/access.log /var/log/nginx/error.log \
    && chown nginx: /var/log/nginx/access.log /var/log/nginx/error.log \
    && ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

STOPSIGNAL SIGTERM

CMD ["nginx", "-g", "daemon off;"]