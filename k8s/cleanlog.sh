#!/bin/sh

echo > /var/log/kube/*
echo > /var/log/kube/kube-apiserver
echo > /var/log/kube/kubelet.log
echo > /var/log/kube/manager_controller
echo > /var/log/kube/proxy.log
echo > /var/log/kube/scheduler
