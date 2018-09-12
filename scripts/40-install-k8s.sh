#!/bin/sh

kubeadm init --config /etc/kubernetes/kubeadm-config.yaml

mkdir -p $HOME/.kube
cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
chown $(id -u):$(id -g) $HOME/.kube/config
mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown vagrant:vagrant /home/vagrant/.kube/config

# Make master as node as well for All-in-one k8s cluster
kubectl taint nodes --all node-role.kubernetes.io/master-

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

# Get token 
admin_user_token=$(kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}') | grep -E '^token' | awk '{print $2}')
echo ""
echo "Kubernetes 已成功安装！后续步骤如下："
echo "================================================================================"
echo "1. 运行以下命令获取配置文件: "
echo ""
echo "   vagrant scp default:/home/vagrant/.kube/config ./`hostname`.conf"
echo ""
echo "2. 本机启动代理访问 Dashboard: "
echo ""
echo "   kubectl --kubeconfig=./`hostname`.conf proxy"
echo ""
echo "3. 使用以下链接访问 Dashboard: "
echo ""
echo "   http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/"
echo ""
echo "4. 使用以下 Token 登陆 Dashboard: "
echo ""
echo "   ${admin_user_token}"
echo ""
echo "================================================================================"
echo ""