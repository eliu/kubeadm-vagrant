# kubeadm-vagrant

本项目利用 Vagrant 和 kubeadm 帮助开发者快速在本地构建单节点 Kubernetes 集群。

[![asciicast](https://asciinema.org/a/uy2vcDXI8WcyTexJ5thImFbe0.png)](https://asciinema.org/a/uy2vcDXI8WcyTexJ5thImFbe0?autoplay=1)

集群特点

1. 支持部署 Kubernetes 的所有主流版本，如 `v1.8.5`, `v1.10.3` 和 `v1.11.2` 等等
2. 使用 Flannel 作为网络插件
3. 自动完成 Dashboard 附加组件的安装部署。
4. **无需翻墙**，适合国内的网络环境

## 安装说明

### 1. 先决条件

以下软件需要提前安装在主机上：

| 软件名称                | 软件版本  | 下载地址/安装命令                              |
| ----------------------- | --------- | ---------------------------------------------- |
| VirtualBox              | 5.2.12+   | https://www.virtualbox.org/wiki/Downloads      |
| Vagrant                 | 2.1.1+    | https://www.vagrantup.com/downloads.html       |
| ~~vagrant-hostmanager~~ | ~~1.8.9~~ | ~~vagrant plugin install vagrant-hostmanager~~ |
| vagrant-scp             | 0.5.7+    | `vagrant plugin install vagrant-scp`           |

### 2. 克隆项目

```bash
git clone https://github.com/eliu/kubeadm-vagrant.git
```

### 3. 配置 k8s 版本（可选）

打开 `/path/to/kubeadm-vagrant/vagrant/Vagrantfile` 并修改全局变量 `K8S_VERSION` 的值，默认值 `1.8.5`

### 4. 启动 Vagrant

启动后将自动安装、更新和配置 kubeadm，最后启动 Kubernetes 集群，命令如下：

```bash
vagrant up
```

### 5. 在主机安装 kubectl

请访问以下地址下载适合您主机平台的 Kubernetes 客户端。

https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG-{K8S_MAJOR}.md

K8S_MAJOR 为 Kubernetes 的主版本，例如 `1.8`, `1.9`, `1.10` 等等。

### 6. 拷贝 Kubernetes 配置文件至主机

```bash
vagrant scp default:/home/vagrant/.kube/config ./kubeadm-master.conf
```

### 7. 检查 Kubernetes 节点状态

```bash
kubectl --kubeconfig=./kubeadm-master.conf get node
```

或者

```bash
export KUBECONFIG=$(PWD)/kubeadm-master.conf
kubectl get node
```

当 Status 为 `Ready` 时证明 Kubernetes 集群的网络插件已经可用。

## 访问 Dashboard

在第5步 `vagrant up` 完成之后会看见如下输出内容，请根据内容提示进行设置以访问 Dashboard 主页。

```
default: ================================================================================
default: 1. 运行以下命令获取配置文件:
default:
default:    vagrant scp default:/home/vagrant/.kube/config ./kubeadm-master.conf
default:
default: 2. 本机启动代理访问 Dashboard:
default:
default:    kubectl --kubeconfig=./kubeadm-master.conf proxy
default:
default: 3. 使用以下链接访问 Dashboard:
default:
default:    http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
default:
default: 4. 使用以下 Token 登陆 Dashboard:
default:
default:    <Token>
default:
default: ================================================================================
```



## 使用反馈

如有任何问题，欢迎在本项目中新建 Issue 进行跟踪，谢谢！