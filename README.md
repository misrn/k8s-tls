# k8s-tls
快速生成kubernetes 所有证书

1. git clone https://github.com/fandaye/k8s-tls.git  && cd k8s-tls/
2. chmod +x ./run.sh
2. 编辑 apiserver.json 文件  对应IP地址及主机名 ，如：      

        {
            "CN": "kube-apiserver",
            "hosts": [
              "172.16.50.112",
              "docker01",
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
