#!/bin/sh
scp /etc/kubernetes/config node2:/etc/kubernetes
scp /lib/systemd/system/kubelet.service node2:/lib/systemd/system
scp /usr/bin/kubelet  node2:/usr/bin/
scp /etc/kubernetes/kubeconfig.yaml node2:/etc/kubernetes
scp /etc/kubernetes/kubelet node2:/etc/kubernetes/

scp /sda6/k8s/easy-rsa-master/easyrsa3/pki/issued/node2.crt node2:/var/kube
scp /sda6/k8s/easy-rsa-master/easyrsa3/pki/private/node2.key node2:/var/kube
scp  /lib/systemd/system/kube-proxy.service node2:/lib/systemd/system
scp -rp /usr/bin/kube-proxy node2:/usr/bin/
scp -rp /etc/kubernetes/proxy node2:/etc/kubernetes

