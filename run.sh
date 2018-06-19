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

cfssl gencert -initca ca.json | cfssljson -bare ca && mv ca.pem ca.crt && mv ca-key.pem ca.key
cfssl gencert -initca front-proxy-ca.json | cfssljson -bare front-proxy-ca  && mv front-proxy-ca.pem front-proxy-ca.crt && mv front-proxy-ca-key.pem front-proxy-ca.key
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=config.json -profile=frognew  apiserver.json | cfssljson -bare apiserver && mv apiserver-key.pem apiserver.key && mv apiserver.pem apiserver.crt
cfssl gencert -ca=ca.crt -ca-key=ca.key -config=config.json -profile=frognew  apiserver-kubelet-client.json | cfssljson -bare apiserver-kubelet-client  && mv apiserver-kubelet-client-key.pem apiserver-kubelet-client.key && mv apiserver-kubelet-client.pem apiserver-kubelet-client.crt
cfssl gencert -ca=front-proxy-ca.crt -ca-key=front-proxy-ca.key -config=config.json -profile=frognew  front-proxy-client.json | cfssljson -bare front-proxy-client && mv front-proxy-client-key.pem front-proxy-client.key && mv front-proxy-client.pem front-proxy-client.crt
openssl genrsa -out sa.key 1024  &&   openssl rsa -in sa.key -pubout -out sa.pub

mkdir -p /etc/kubernetes/pki
cp config.json kubernetes-admin.json kubelet.json kube-controller-manager.json  kube-scheduler.json /etc/kubernetes/pki/
cp node.sh apiserver.crt apiserver-kubelet-client.crt  ca.crt front-proxy-ca.key front-proxy-client.key  sa.pub  apiserver.key apiserver-kubelet-client.key  ca.key  front-proxy-ca.crt  front-proxy-client.crt  sa.key /etc/kubernetes/pki/

rm *.crt  *.csr *.key *.pub *.conf -rf
