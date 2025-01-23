FROM ubuntu:20.04

ENV DEBIAN_FRONTEND=noninteractive

# Install strongSwan
RUN apt-get update && \
    apt-get install -y \
    strongswan \
    libstrongswan-standard-plugins \
    libcharon-extra-plugins \
    && rm -rf /var/lib/apt/lists/*

# Create VPN user
RUN echo 'vpnuser : EAP "vpnpassword"' > /etc/ipsec.secrets && \
    chmod 600 /etc/ipsec.secrets

# Create basic ipsec config
RUN echo 'config setup\n\
    charondebug="ike 2, knl 2, cfg 2"\n\
    uniqueids=no\n\
\n\
conn ikev2-vpn\n\
    auto=add\n\
    compress=no\n\
    type=tunnel\n\
    keyexchange=ikev2\n\
    fragmentation=yes\n\
    forceencaps=yes\n\
    ike=aes256-sha256-modp2048\n\
    esp=aes256-sha256\n\
    dpdaction=clear\n\
    dpddelay=300s\n\
    rekey=no\n\
    left=%any\n\
    leftauth=psk\n\
    leftid=@vpn.server\n\
    leftsubnet=0.0.0.0/0\n\
    right=%any\n\
    rightauth=eap-mschapv2\n\
    rightsourceip=10.10.10.0/24\n\
    rightdns=8.8.8.8,8.8.4.4\n\
    eap_identity=%identity' > /etc/ipsec.conf

# Add PSK (Pre-Shared Key)
RUN echo ': PSK "your-strong-psk-key"' >> /etc/ipsec.secrets

EXPOSE 500/udp 4500/udp

CMD ["ipsec", "start", "--nofork"]
