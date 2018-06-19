#!/bin/bash


if [ ! -f "/usr/bin/cfssl" ]; then
echo "/usr/bin/cfssl 不存在，异常退出!"
exit 1
fi

if [ ! -f "/usr/bin/cfssljson" ]; then
echo "/usr/bin/cfssljson 不存在，异常退出!"
exit 1
fi

ip="172.16.50.132"
NODE="k8s02"

cfssl gencert -ca=ca.crt -ca-key=ca.key -config=config.json -profile=frognew  kubernetes-admin.json | cfssljson -bare kubernetes-admin && mv kubernetes-admin.pem kubernetes-admin.crt && mv kubernetes-admin-key.pem kubernetes-admin.key
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=config.json -profile=frognew  kubelet.json | cfssljson -bare kubelet  && mv kubelet-key.pem  kubelet.key  && mv kubelet.pem kubelet.crt
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=config.json -profile=frognew  kube-controller-manager.json | cfssljson -bare kube-controller-manager && mv kube-controller-manager.pem kube-controller-manager.crt && mv kube-controller-manager-key.pem kube-controller-manager.key
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=config.json -profile=frognew  kube-scheduler.json | cfssljson -bare kube-scheduler && mv kube-scheduler.pem kube-scheduler.crt && mv kube-scheduler-key.pem kube-scheduler.key

  
kubectl config set-cluster kubernetes --certificate-authority=ca.crt --embed-certs=true --server=https://${ip}:6443 --kubeconfig=admin.conf
kubectl config set-credentials kubernetes-admin --client-certificate=kubernetes-admin.crt --embed-certs=true --client-key=kubernetes-admin.key --kubeconfig=admin.conf
kubectl config set-context kubernetes-admin@kubernetes --cluster=kubernetes --user=kubernetes-admin --kubeconfig=admin.conf
kubectl config use-context kubernetes-admin@kubernetes --kubeconfig=admin.conf

kubectl config set-cluster kubernetes --certificate-authority=ca.crt --embed-certs=true --server=https://${ip}:6443 --kubeconfig=kubelet.conf
kubectl config set-credentials system:node:${NODE} --client-certificate=kubelet.crt --embed-certs=true --client-key=kubelet.key --kubeconfig=kubelet.conf
kubectl config set-context system:node:${NODE}@kubernetes --cluster=kubernetes --user=system:node:${NODE} --kubeconfig=kubelet.conf
kubectl config use-context system:node:${NODE}@kubernetes --kubeconfig=kubelet.conf

kubectl config set-cluster kubernetes --certificate-authority=ca.crt --embed-certs=true --server=https://${ip}:6443 --kubeconfig=controller-manager.conf
kubectl config set-credentials system:kube-controller-manager --client-certificate=kube-controller-manager.crt --embed-certs=true --client-key=kube-controller-manager.key --kubeconfig=controller-manager.conf
kubectl config set-context system:kube-controller-manager@kubernetes --cluster=kubernetes --user=system:kube-controller-manager --kubeconfig=controller-manager.conf
kubectl config use-context system:kube-controller-manager@kubernetes --kubeconfig=controller-manager.conf

kubectl config set-cluster kubernetes --certificate-authority=ca.crt --embed-certs=true --server=https://${ip}:6443 --kubeconfig=scheduler.conf
kubectl config set-credentials system:kube-scheduler --client-certificate=kube-scheduler.crt --embed-certs=true --client-key=kube-scheduler.key --kubeconfig=scheduler.conf
kubectl config set-context system:kube-scheduler@kubernetes --cluster=kubernetes --user=system:kube-scheduler --kubeconfig=scheduler.conf
kubectl config use-context system:kube-scheduler@kubernetes  --kubeconfig=scheduler.conf

mv *.conf /etc/kubernetes/
rm kubernetes-admin.crt kubernetes-admin.key kubelet.crt kubelet.key kube-controller-manager.crt kube-controller-manager.key kube-scheduler.crt kube-scheduler.key -rf
rm *.conf -rf
rm *.csr -rf
