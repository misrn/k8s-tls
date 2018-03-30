#!/bin/bash

chmod +x ./bin -R
cp ./bin/* /usr/bin/ -a

if [ ! -f "/usr/bin/cfssl" ]; then
echo "/usr/bin/cfssl 不存在，异常退出!"
exit 1
fi

if [ ! -f "/usr/bin/cfssljson" ]; then
echo "/usr/bin/cfssljson 不存在，异常退出!"
exit 1
fi

ip="172.16.50.112"

cfssl gencert -initca ca.json | cfssljson -bare ca && mv ca.pem ca.crt && mv ca-key.pem ca.key
cfssl gencert -initca front-proxy-ca.json | cfssljson -bare front-proxy-ca  && mv front-proxy-ca.pem front-proxy-ca.crt && mv front-proxy-ca-key.pem front-proxy-ca.key
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=config.json -profile=frognew  apiserver.json | cfssljson -bare apiserver && mv apiserver-key.pem apiserver.key && mv apiserver.pem apiserver.crt
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=config.json -profile=frognew  apiserver-kubelet-client.json | cfssljson -bare apiserver-kubelet-client  && mv apiserver-kubelet-client-key.pem apiserver-kubelet-client.key && mv apiserver-kubelet-client.pem apiserver-kubelet-client.crt
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=config.json -profile=frognew  kubernetes-admin.json | cfssljson -bare kubernetes-admin && mv kubernetes-admin.pem kubernetes-admin.crt && mv kubernetes-admin-key.pem kubernetes-admin.key
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=config.json -profile=frognew  kubelet.json | cfssljson -bare kubelet  && mv kubelet-key.pem  kubelet.key  && mv kubelet.pem kubelet.crt
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=config.json -profile=frognew  kube-controller-manager.json | cfssljson -bare kube-controller-manager && mv kube-controller-manager.pem kube-controller-manager.crt && mv kube-controller-manager-key.pem kube-controller-manager.key
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=config.json -profile=frognew  kube-scheduler.json | cfssljson -bare kube-scheduler && mv kube-scheduler.pem kube-scheduler.crt && mv kube-scheduler-key.pem kube-scheduler.key
cfssl gencert -ca=front-proxy-ca.crt -ca-key=front-proxy-ca.key -config=config.json -profile=frognew  front-proxy-client.json | cfssljson -bare front-proxy-client && mv front-proxy-client-key.pem front-proxy-client.key && mv front-proxy-client.pem front-proxy-client.crt
openssl genrsa -out sa.key 1024  &&   openssl rsa -in sa.key -pubout -out sa.pub

  
kubectl config set-cluster kubernetes --certificate-authority=ca.crt --embed-certs=true --server=https://${ip}:6443 --kubeconfig=admin.conf
kubectl config set-credentials kubernetes-admin --client-certificate=kubernetes-admin.crt --embed-certs=true --client-key=kubernetes-admin.key --kubeconfig=admin.conf
kubectl config set-context kubernetes-admin@kubernetes --cluster=kubernetes --user=kubernetes-admin --kubeconfig=admin.conf
kubectl config use-context kubernetes-admin@kubernetes --kubeconfig=admin.conf

kubectl config set-cluster kubernetes --certificate-authority=ca.crt --embed-certs=true --server=https://${ip}:6443 --kubeconfig=kubelet.conf
kubectl config set-credentials system:node:docker01 --client-certificate=kubelet.crt --embed-certs=true --client-key=kubelet.key --kubeconfig=kubelet.conf
kubectl config set-context system:node:docker01@kubernetes --cluster=kubernetes --user=system:node:docker01 --kubeconfig=kubelet.conf
kubectl config use-context system:node:docker01@kubernetes --kubeconfig=kubelet.conf

kubectl config set-cluster kubernetes --certificate-authority=ca.crt --embed-certs=true --server=https://${ip}:6443 --kubeconfig=controller-manager.conf
kubectl config set-credentials system:kube-controller-manager --client-certificate=kube-controller-manager.crt --embed-certs=true --client-key=kube-controller-manager.key --kubeconfig=controller-manager.conf
kubectl config set-context system:kube-controller-manager@kubernetes --cluster=kubernetes --user=system:kube-controller-manager --kubeconfig=controller-manager.conf
kubectl config use-context system:kube-controller-manager@kubernetes --kubeconfig=controller-manager.conf

kubectl config set-cluster kubernetes --certificate-authority=ca.crt --embed-certs=true --server=https://${ip}:6443 --kubeconfig=scheduler.conf
kubectl config set-credentials system:kube-scheduler --client-certificate=kube-scheduler.crt --embed-certs=true --client-key=kube-scheduler.key --kubeconfig=scheduler.conf
kubectl config set-context system:kube-scheduler@kubernetes --cluster=kubernetes --user=system:kube-scheduler --kubeconfig=scheduler.conf
kubectl config use-context system:kube-scheduler@kubernetes  --kubeconfig=scheduler.conf

mkdir -p /etc/kubernetes/pki
cp apiserver.crt apiserver.key apiserver-kubelet-client.crt apiserver-kubelet-client.key ca.crt ca.key  front-proxy-ca.crt  front-proxy-ca.key  front-proxy-client.crt  front-proxy-client.key  sa.key  sa.pub /etc/kubernetes/pki/

cp admin.conf controller-manager.conf kubelet.conf scheduler.conf /etc/kubernetes/


