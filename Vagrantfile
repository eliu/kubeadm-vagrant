# -*- mode: ruby -*-
# vi: set ft=ruby :
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
NETWORK_IP  = '192.168.119.101'
HOSTNAME    = 'k8s-master'
K8S_VERSION = 'v1.11.2'

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7"
  config.vm.network "private_network", ip: "#{NETWORK_IP}"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.provision "shell", inline: <<-SHELL
    export K8S_VERSION=#{K8S_VERSION}
    export ADVERTISE_ADDR=#{NETWORK_IP}

    hostnamectl set-hostname #{HOSTNAME}
    echo "#{NETWORK_IP} #{HOSTNAME}" >> /etc/hosts
  
    echo "Pre-config system ..."
    /vagrant/scripts/10-pre-config.sh

    # echo "Installing packages ..."
    # yum -y update && yum -y upgrade
    /vagrant/scripts/20-install-docker.sh

    echo "Installing kubeadm ..."
    /vagrant/scripts/30-install-kubeadm.sh

    echo "Installing k8s using kubeadm ..."
    /vagrant/scripts/40-install-k8s.sh
  SHELL
end
