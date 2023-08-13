#!/usr/bin/env sh

if ! command -v openvpn >/dev/null; then
  exit 1
fi

if [ ! -f /root/ca.crt ]; then
  git -c advice.detachedHead=false clone -b v3.1.2 --depth 1 https://github.com/OpenVPN/easy-rsa.git /usr/local/share/easy-rsa/
  ln -s /usr/local/share/easy-rsa/easyrsa3/easyrsa /usr/local/bin
  chmod 755 /usr/local/bin/easyrsa

  easyrsa init-pki
  easyrsa build-ca
  easyrsa build-server-full server
  easyrsa build-client-full "${UPN}"
fi

cat > "/etc/openvpn/openvpn.conf" <<EOF
        dev tun0
        server 100.64.0.0 255.255.255.0
        verb 3
        ca /root/ca.crt
        key /root/server.key
        cert /root/server.crt
        dh none
        keepalive 10 60
        persist-key
        persist-tun
        explicit-exit-notify

        tls-cert-profile preferred

        topology subnet
        proto udp
        port 1194

        fast-io
        user nobody
        group nogroup

        reneg-sec 60
        script-security 3
        plugin /usr/lib/openvpn/plugins/openvpn-auth-ldap.so /root/ldap.conf
        #auth-user-pass-verify "/bin/env" via-env
        #auth-user-pass-verify /usr/local/bin/openvpn-auth-azure-ad via-file
        #auth-user-pass-optional
        #auth-gen-token 300 120
        #auth-token-user YXV0aC10b2tlbg==
        #push "auth-token-user YXV0aC10b2tlbg=="
EOF

cat > "/etc/openvpn/${UPN}.ovpn" <<EOF
        client
        dev tun
        nobind
        remote localhost 1194 udp4
        remote-cert-tls server
        resolv-retry infinite
        tls-cert-profile preferred
        persist-tun
        verb 3
        <key>
        $(cat /etc/openvpn/pki/private/"${UPN}".key)
        </key>
        <cert>
        $(openssl x509 -in /etc/openvpn/pki/issued/"${UPN}".crt)
        </cert>
        <ca>
        $(cat /etc/openvpn/pki/ca.crt)
        </ca>
EOF

exec openvpn --genkey secret "/etc/openvpn/ta.key"
exec openvpn --config "/etc/openvpn/openvpn.conf"
