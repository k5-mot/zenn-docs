---
title: "Kubernetes"
---

# Kubernetesにおけるデプロイ

- コンテナイメージをデプロイする
- Kubernetesでは、Podがコンテナを起動するための最小単位のリソース
  - コンテナ = Pod (ただ、実際には1対1で使う)
- デプロイするには、Kubernetes用のYAMLファイルを作成する

```bash
eksctl create cluster -f cluster_v1.yaml
kubectl run nginx --image nginx:latest -o yaml --dry-run > nginx_v1.yaml
kubectl apply -f nginx_v1.yaml
kubectl get pods
kubectl port-forward nginx 8080:80
# 別タブで以下のコマンド
curl 127.0.0.1:8080

<Ctrl+C>
```

# Service

- Service リソースについて
  - 外部からpodに接続するためのネットワークを扱うリソース群
  - NodePortリソースもその１つ
  - NodePortは,Kubernetesで動作しているすべてのNodeが同じポート番号を受け付けることで、外部からの接続を受け付ける
  - Kubernetesでは、Node上でPodが起動する
  - Nodeは1つのVMや物理マシンを抽象化したリソースである


```bash
kubectl create service nodeport nginx --tcp=80:80 --dry-run -o yaml
kubectl apply -f nginx_v2.yaml
kubectl get svc # ポートを確認
kubectl get pod -o wide
# Security Groupで確認したポートを開ける
# EC2のPublic IPを確認
# ブラウザで、http://<Public IP>:<Port>を開く
```

- ec2 sg設定
- 基本的な詳細
  - セキュリティグループ名
    - nginx-nodeport
  - 説明
    - nginx-nodeport
  - VPC
    - vpc-0c9f66c5174477b42 (eksctl-eks-study-cluster-cluster/VPC)
- インバウンドルール
  - カスタムTCP
  - ポート範囲: 32662
  - 送信先0.0.0.0/0

- eksctlで作成したnode(ec2)にセキュリティグループを適用
- http://3.113.245.129:32662/をブラウザで開く
- EC2に適用したSGを削除

# ALBを置く

- Nodeを削除

```bash
eksctl delete nodegroup -f cluster_v1.yaml --approve
kubectl get pod
eksctl create nodegroup -f cluster_v2.yaml
kubectl get pod
kubectl apply -f nginx_v2.yaml
kubectl get pod
```

- AWS Load balancer controllerをインストール
  - [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/deploy/installation/#add-controller-to-cluster)
    - YAML manifests

```bash
kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v1.12.3/cert-manager.yaml
wget https://github.com/kubernetes-sigs/aws-load-balancer-controller/releases/download/v2.7.0/v2_7_0_full.yaml
ls
sed -i "" "s/<your-cluster-name>/eks-study-cluster/" v2_7_0_full.yaml
kubectl apply -f v2_7_0_full.yaml
kubectl get pods --all-namespaces
```

- Ingressを作る
```bash
kubectl create ingress nginx --dry-run=client -o yaml --rule="/*"=nginx:80 > nginx-ingress_v1.yaml
kubectl apply -f nginx-ingress_v1.yaml
# マネジメントコンソールからALBが作成されているか確認する
# DNS名をブラウザでアクセス
```

# HTTPS化する

ACM

```bash
kubectl delete -f nginx-ingress_v1.yaml
kubectl apply -f nginx-ingress_v2.yaml # アノテーションにcertificate-arnを追加
# DNS名をブラウザでアクセス
```


# ヘルスチェック

- Podレベルでのヘルスチェック
- Liveness Probe
  - Podが正常に動作しているかを確認する
- Readiness Probe
  - Podがサービスインする準備ができているかを確認する

```bash
kubectl delete -f nginx-ingress_v2.yaml
kubectl apply -f nginx_v3.yaml
kubectl get pod
kubectl exec nginx -it /bin/sh
rm /usr/share/nginx/html/index.html
kubectl get pods
kubectl get pods -w # コンテナが再起動する。Ctrl_Cで止める
kubectl describe pods nginx # Readiness Liveness Probeの失敗が確認できる
```

# Deployment

- Kubernetesで推奨されているコンテナ起動方法
- Deployment > ReplicaSet > pod
- Podの起動数が常に期待どうりになる
- ローリングアップデートによるPodのアップデート

```bash
kubectl delete -f nginx_v3.yaml
kubectl create deployment nginx --image nginx:latest -o yaml --dry-run=client
kubectl apply  -f nginx_v4.yaml # Deploy + Service
kubectl get deployments.apps
kubectl get pods
```

# Horizontal Pod Autoscaler（HPA）

- Podレベルでオートスケーリングを行う機能
- CPU、メモリ使用率といったメトリクスを基準にスケーリングする
- 実際のリソース使用率を取得する必要がある
  - [metrics-server](https://github.com/kubernetes-sigs/metrics-server)を利用する


```bash
kubectl delete -f nginx_v4.yaml # Deploy + Service
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl top node # CPU,メモリ使用率の確認ができる
kubectl apply -f nginx_v5.yaml # メトリクスの設定を追加
kubectl autoscale deployment nginx --cpu-percent 50 --min 1 --max 10
kubectl get horizontalpodautoscalers.autoscaling
kubectl run apache-bench -i --tty --rm --image httpd -- /bin/sh
while true; do ab -n 10 -c 10 http://nginx.default.svc.cluster.local/ > /dev/null; done
kubectl get pods -w # Podが増えているのが確認できる
kubectl get hpa
kubectl get pods
```

# Cluster Autoscaler

- Kubernetesで、Nodeのオートスケーリングを行うためのプログラム
- 各種クラウドプロバイダーの仕組みに沿って、オートスケーリングできるように実装されている
- AWSでは、Auto Scaling Groupを使用して、スケーリングが行われる

```bash
eksctl delete nodegroup -f cluster_v2.yaml --approve
eksctl create nodegroup -f cluster_v3.yaml
wget https://raw.githubusercontent.com/kubernetes/autoscaler/master/cluster-autoscaler/cloudprovider/aws/examples/cluster-autoscaler-autodiscover.yaml
# 138行目のバージョンをKubernetesのクラスタに合わせる
# 157行目にクラスタ名を入力
kubectl apply -f cluster-autoscaler-autodiscover.yaml
kubectl get pods -n kube-system
kubectl scale deployment --replicas 10 nginx
kubectl get pods -w # 10このPodが起動する
kubectl get node -w # 2個に増える
```
