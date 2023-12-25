#!/usr/bin/env bash
set -e
#===  FUNCTION  ================================================================
#         NAME: kubeadm_init
#  DESCRIPTION: Launch kubeadm to bring up a k8s cluster.
#	       SCOPE: normal
# PARAMETER  1:  
#===============================================================================
function kubeadm_init() {
  kubeadm init --config /etc/kubernetes/kubeadm-config.yaml
}

#===  FUNCTION  ================================================================
#         NAME: grant_users
#  DESCRIPTION: Grant user root and vagrant to be able to access k8s.
#	       SCOPE: normal
# PARAMETER  1:  
#===============================================================================
function grant_users() {
  mkdir -p $HOME/.kube
  cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
  chown $(id -u):$(id -g) $HOME/.kube/config
  mkdir -p /home/vagrant/.kube
  cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
  chown vagrant:vagrant /home/vagrant/.kube/config
}

#===  FUNCTION  ================================================================
#         NAME: taint_masters
#  DESCRIPTION: Make master nodes schedulable
#	       SCOPE: normal
# PARAMETER  1:  
#===============================================================================
function taint_masters() {
  kubectl taint nodes --all node-role.kubernetes.io/master-
}

#===  FUNCTION  ================================================================
#         NAME: install_addons
#  DESCRIPTION: Install k8s addons
#	       SCOPE: normal
# PARAMETER  1:  
#===============================================================================
function install_addons(){
  # Install network plugin flannel
  kubectl apply -f /vagrant/addons/kube-flannel.yml
  # Install nginx ingress controller
  echo "[`hostname`] Applying addon nginx ingress controller ..."
  kubectl apply -f /vagrant/addons/ingress-nginx.yaml
  # Install Dashboard
  echo "[`hostname`] Applying addon dashboard ..."
  kubectl apply -f /vagrant/addons/kubernetes-dashboard.yaml
  # Create admin-user role
  echo "[`hostname`] Creating admin-user role ..."
  kubectl apply -f /vagrant/addons/admin-user-role.yaml
}

function main() {
  echo "Installing k8s using kubeadm ..."
  kubeadm_init
  grant_users
  taint_masters
  install_addons

  # Get token 
  admin_user_token=$(kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') | grep -E '^token' | awk '{print $2}')

  cat << "EOF"

    __         __                   __                                                  __ 
   / /____  __/ /_  ___  ____ _____/ /___ ___       _   ______ _____ __________ _____  / /_
  / //_/ / / / __ \/ _ \/ __ `/ __  / __ `__ \_____| | / / __ `/ __ `/ ___/ __ `/ __ \/ __/
 / ,< / /_/ / /_/ /  __/ /_/ / /_/ / / / / / /_____/ |/ / /_/ / /_/ / /  / /_/ / / / / /_  
/_/|_|\__,_/_.___/\___/\__,_/\__,_/_/ /_/ /_/      |___/\__,_/\__, /_/   \__,_/_/ /_/\__/  
                                                            /____/                        
                                                                                      
EOF

  cat << EOF
Kubernetes 已成功安装！后续步骤如下：
================================================================================
1. 运行以下命令获取配置文件: 

  vagrant scp default:/home/vagrant/.kube/config ./`hostname`.conf

2. 本机启动代理访问 Dashboard: 

  kubectl --kubeconfig=./`hostname`.conf proxy

3. 使用以下链接访问 Dashboard: 

  http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/

4. 使用以下 Token 登陆 Dashboard: 

  ${admin_user_token}

================================================================================

EOF
}

main