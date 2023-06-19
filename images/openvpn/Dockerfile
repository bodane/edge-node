FROM alpine:latest as build

RUN apk add --no-cache linux-pam apache2-utils build-base linux-pam-dev openvpn

COPY --chmod=0777 ./bin/ /usr/bin

WORKDIR /root

EXPOSE 1194/udp

COPY ./conf/* /root

ENTRYPOINT ["openvpn", "--config", "client-cert-ftm.conf"]
