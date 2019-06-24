#!/bin/sh
if [[ $1 == "restart" ]]; then
	systemctl restart docker etcd kube-apiserver  kubelet.service  kube-proxy.service  kube-scheduler.service kube-controller-manager
elif [[ $1 == "status" ]]; then
	systemctl status docker etcd kube-apiserver  kubelet.service  kube-proxy.service  kube-scheduler.service kube-controller-manager | grep Active
fi
