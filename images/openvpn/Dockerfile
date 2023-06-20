FROM alpine:latest as build

RUN apk add --no-cache openvpn openvpn-auth-ldap openssl bash git

COPY --chmod=0777 ./bin/ /usr/bin

WORKDIR /root

EXPOSE 1194/udp

COPY ./conf/* /root

ENTRYPOINT ["docker-entrypoint.sh"]
