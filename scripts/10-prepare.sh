#!/usr/bin/env bash
set -e
source $MODULE_ROOT/logging.sh
readonly MODULE_NAME="PREPARE"
readonly CONFIG_HOME="/vagrant/etc"

prepare::selinux() {
  [[ "Permissive" = $(getenforce selinux) ]] || {
    log::info "Setup selinux..."
    setenforce 0
    sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=permissive/g' c
  }
}

prepare::disable_swap() {
  grep '#.*swap' /etc/fstab >/dev/null 2>&1 || {
    log::info "Disable swap..."
    sed -ri 's/(.*swap.*)/#\1/g' /etc/fstab
    swapoff -a
  }
}

prepare::ports() {
  firewall-cmd --list-services >/dev/null 2>&1 || {
    log::info "Setup firewall for opening ports..."
    systemctl enable --now firewalld >/dev/null 2>&1
    \cp -f $CONFIG_HOME/k8s/service.xml /etc/firewalld/services/k8s.xml
    firewall-cmd --permanent --add-service k8s >/dev/null 2>&1
    firewall-cmd --reload >/dev/null 2>&1
    # firewall-cmd --info-service k8s
  }
}

prepare::sysctl() {
  [[ -f /etc/sysctl.d/k8s.conf ]] || {
    log::info "Twicking kernel..."
    # 微调系统内核
    \cp -f $CONFIG_HOME/k8s/sysctl.conf /etc/sysctl.d/k8s.conf
    # 使系统设置生效
    sysctl --system > /dev/null
  }
}

prepare::repo() {
  [[ -f /etc/yum.repos.d/k8s.repo ]] || {
    log::info "Setup k8s repo..."
    \cp -f $CONFIG_HOME/k8s/k8s.repo /etc/yum.repos.d/k8s.repo
  }
}

prepare::hostname() {
  grep $VG_MACHINE_HOSTNAME /etc/hosts >/dev/null 2>&1 || {
    log::info "Setup hostname..."
    hostnamectl set-hostname $VG_MACHINE_HOSTNAME
    echo "$VG_MACHINE_IP $VG_MACHINE_HOSTNAME" >> /etc/hosts
  }
}

{
  prepare::selinux
  prepare::disable_swap
  prepare::ports
  prepare::sysctl
  prepare::repo
  prepare::hostname
}
