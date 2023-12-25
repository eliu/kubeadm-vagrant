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
MACHINE_IP  = '192.168.119.101'
MACHINE_HOSTNAME = 'k8s-master'
K8S_VERSION = 'v1.11.2'

Vagrant.configure("2") do |config|
  config.vm.box = "bento/centos-7"
  config.vm.box_check_update = false
  config.vm.network "private_network", ip: "#{MACHINE_IP}"
  config.vm.provider "virtualbox" do |vb|
    vb.memory = 2048
    vb.cpus = 2
  end

  config.vm.provision "shell", keep_color: true, inline: <<-SHELL
    export K8S_VERSION=#{K8S_VERSION}
    export K8S_ADVERTISE_ADDR=#{MACHINE_IP}
    export VG_MACHINE_IP=#{MACHINE_IP}
    export VG_MACHINE_HOSTNAME=#{MACHINE_HOSTNAME}
    export MODULE_ROOT="/vagrant/lib/modules"
    source $MODULE_ROOT/logging.sh
    source $MODULE_ROOT/network.sh

    network::resolve_dns

    for path_to_script in $(ls /vagrant/scripts/*.sh); do
      $path_to_script
    done
  SHELL
end
