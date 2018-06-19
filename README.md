# k8s-tls
快速生成kubernetes 所有证书

1. git clone https://github.com/fandaye/k8s-tls.git  && cd k8s-tls/
2. chmod +x ./run.sh
2. 编辑 apiserver.json 文件  对应IP地址及主机名 ，如：      

        {
            "CN": "kube-apiserver",
            "hosts": [
              "xx.xx.xx.xx",
              "nodename",
              "10.96.0.1",
              "kubernetes",
              "kubernetes.default",
              "kubernetes.default.svc",
              "kubernetes.default.svc.cluster",
              "kubernetes.default.svc.cluster.local"     
            ],
            "key": {
                "algo": "rsa",
                "size": 2048
            }
        }
     
4. 执行./run.sh
5. 进入/etc/kubernetes/pki/编辑node.sh文件

        ip="xx.xx.xx.xx"
        NODE="nodename"
        
6. 编辑kubelet.json文件

        .....
        "CN": "system:node:nodename",
        ......

7. 执行./node.sh
