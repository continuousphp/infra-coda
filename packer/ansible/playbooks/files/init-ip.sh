#!/bin/bash -xe

MyIpAdress=$(curl http://169.254.169.254/latest/meta-data/public-ipv4)
S3_PASSWORD=$(cat /opt/coda/my-wallet.password)
S3_PUBLIC_KEY=$(cat /opt/coda/my-wallet.pub)

export MYIP=${MyIpAdress}
export Password=${S3_PASSWORD}
export PublicKey=${S3_PUBLIC_KEY}

envsubst < /home/coda/coda-systemd/coda-config > /etc/default/coda-config
