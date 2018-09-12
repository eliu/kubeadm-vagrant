#!/bin/sh

yum -y install docker socat
usermod -aG dockerroot vagrant
# http://docker-cn.com/registry-mirror
cat > /etc/docker/daemon.json <<EOF
{
    "group": "dockerroot",
    "registry-mirrors": ["https://registry.docker-cn.com"]
}
EOF
systemctl enable docker
systemctl start docker
