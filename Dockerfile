FROM caddy:2-alpine

LABEL org.opencontainers.image.authors="r.anerg@gmail.com"

ARG V2R_VERSION=v5.1.0
ARG DOMAIN
ARG EMAIL


ENV TZ              Asia/Shanghai
ENV DOMAIN          ${DOMAIN}
ENV EMAIL           ${EMAIL}
ENV V2R_URL         https://github.com/v2fly/v2ray-core/releases/download/${V2R_VERSION}/v2ray-linux-arm64-v8a.zip
ENV V2R_PATH_CONF   /etc/v2ray
ENV CADDY_PATH_CONF /etc/caddy

ADD boot.sh /usr/bin

COPY conf/ /conf/
COPY html/ /var/www/v2ray/ 

RUN set -xe \
    && apk -U upgrade \
    && apk add --update --no-cache --virtual .build-deps \
    tzdata \
    curl \
    && mkdir -p \
    ${CADDY_PATH_CONF} \
    ${V2R_PATH_CONF} \
    && cp /usr/share/zoneinfo/${TZ} /etc/localtime \
    && curl -L -H "Cache-Control: no-cache" -o /tmp/v2ray.zip ${V2R_URL} \
    && unzip /tmp/v2ray.zip -d /tmp/ \
    && mv /tmp/v2ray /usr/bin/ \
    && chmod +x /usr/bin/v2ray \
    && chmod +x /usr/bin/boot.sh \
    # 删除不必要的东西
    && apk del .build-deps \
    && rm -rf /tmp/* \
    && rm /etc/caddy/Caddyfile \
    && apk add uuidgen openrc

EXPOSE 80 443

ENTRYPOINT ["/usr/bin/boot.sh"]
