#!/bin/sh

K8S_YUM_VERSION=`echo $K8S_VERSION | cut -c 2-`
# kubelet >= 1.9.0 requires kubernetes-cni 0.6.0
# kubelet >= 1.5.4 requires kubernetes-cni 0.5.1 
K8S_MINOR=`echo $K8S_YUM_VERSION | awk -F'.' '{print $2}'`
if [[ $K8S_MINOR -ge 9 ]]; then
    CNI_VERSION=0.6.0
else
    CNI_VERSION=0.5.1
fi
yum install -y \
    kubelet-$K8S_YUM_VERSION \
    kubeadm-$K8S_YUM_VERSION \
    kubectl-$K8S_YUM_VERSION \
    kubernetes-cni-$CNI_VERSION

systemctl enable kubelet
systemctl start kubelet

mkdir -p /etc/systemd/system/kubelet.service.d
cat > /etc/systemd/system/kubelet.service.d/20-kubeadm-override.conf <<EOF
[Service]
Environment="KUBELET_EXTRA_ARGS=--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.1"
EOF
chmod +x /etc/systemd/system/kubelet.service.d/20-kubeadm-override.conf

echo "KUBELET_EXTRA_ARGS=--pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.1" > /etc/sysconfig/kubelet
chmod +x /etc/sysconfig/kubelet

systemctl daemon-reload
systemctl restart kubelet

cat > /etc/kubernetes/kubeadm-config.yaml <<EOF
apiVersion: kubeadm.k8s.io/v1alpha1
kind: MasterConfiguration
api:
  advertiseAddress: "$ADVERTISE_ADDR"
networking:
  podSubnet: "10.244.0.0/16"
kubernetesVersion: "$K8S_VERSION"
imageRepository: "registry.cn-hangzhou.aliyuncs.com/google_containers"
EOF
