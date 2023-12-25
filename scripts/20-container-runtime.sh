#!/usr/bin/env bash
set -e
command -v docker >/dev/null 2>&1 || {
  echo "Installing container runtime [docker]..."
  yum install -q -y docker socat >/dev/null 2>&1 
  usermod -aG dockerroot vagrant
  \cp -f /vagrant/etc/docker/daemon.json /etc/docker/daemon.json
  systemctl enable --now docker >/dev/null 2>&1 
}
