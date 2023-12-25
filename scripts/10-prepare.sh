#!/usr/bin/env bash
#
# Copyright 2018 Liu Hongyu
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
prepare::disable_selinux() {
  setenforce 0
  sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
}

prepare::disable_swap() {
  sed -ri 's/(.*swap.*)/#\1/g' /etc/fstab
  swapoff -a
}

prepare::disable_firewall() {
  # 禁用防火墙
  systemctl disable firewalld
  systemctl stop firewalld
}

prepare::sysctl() {
  # 微调系统内核
  \cp -f /vagrant/etc/kubernetes/sysctl.conf /etc/sysctl.d/k8s.conf
  # 使系统设置生效
  sysctl --system > /dev/null
}

prepare::repo() {
  # 设置 K8S 软件源
  \cp -f /vagrant/etc/kubernetes/kubernetes.repo /etc/yum.repos.d/kubernetes.repo
}

prepare::hostname() {
  hostnamectl set-hostname $VG_MACHINE_HOSTNAME
  echo "$VG_MACHINE_IP $VG_MACHINE_HOSTNAME" >> /etc/hosts
}

{
  echo "Pre-config system..."
  prepare::disable_selinux
  prepare::disable_swap
  prepare::disable_firewall
  prepare::sysctl
  prepare::repo
  prepare::hostname
}
