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

# ConfigMap

- Kubernetesでは、COnfigMap、Secretが環境変数を扱うためのリソースである
- COnfigMapは設定情報を保存するためのリソース
- Secretは、設定情報の中でもパスワードなどの機密情報を保存するためのリソース

```bash
# ConfigMap作成
kubectl get deployments.apps
kubectl get pods
touch env
kubectl create configmap eks-study --from-env-file=env
kubectl apply -f nginx_v6.yaml
kubectl get pods
kubectl exec -it nginx-66564f5d9f-965b9 env

# ConfigMap更新
kubectl describe configmaps eks-study
kubectl edit configmap eks-study
kubectl exec -it nginx-66564f5d9f-965b9 env # 更新されない
kubectl rollout restart deployment/nginx
kubectl get pods
kubectl exec -it nginx-66564f5d9f-965b9 env # 更新される

# Secret作成
kubectl get deployments.apps
kubectl create secret generic eks-study --from-literal=DB_USER=root --from-literal=DB_PASSWORD=password
kubectl describe secret eks-study
kubectl get secret eks-study -o yaml
echo 'cGFzc3dvcmQ=' | base64 --decode
kubectl apply -f nginx_v7.yaml
kubectl exec -it nginx-66564f5d9f-965b9 env
```


# 監視設定

- [Cloudwatch Container Insights](https://docs.aws.amazon.com/ja_jp/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-EKS-quickstart.html)では、Amazon EKS上のアプリケーションのメトリクスとログを収集、集計、可視化できる
- CloudWatchの機能で、ダッシュボード上でメトリクスを可視化したり、メトリクスやログにアラームを設定し、通知を行うことができる

```bash
eksctl delete nodegroup -f cluster_v3.yaml --approve
eksctl create nodegroup -f cluster_v4.yaml
ClusterName='eks-study-cluster'
RegionName='ap-northeast-1'
FluentBitHttpPort='2020'
FluentBitReadFromHead='Off'
[[ ${FluentBitReadFromHead} = 'On' ]] && FluentBitReadFromTail='Off'|| FluentBitReadFromTail='On'
[[ -z ${FluentBitHttpPort} ]] && FluentBitHttpServer='Off' || FluentBitHttpServer='On'
curl https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/quickstart/cwagent-fluent-bit-quickstart-enhanced.yaml | sed 's/{{cluster_name}}/'${ClusterName}'/;s/{{region_name}}/'${RegionName}'/;s/{{http_server_toggle}}/"'${FluentBitHttpServer}'"/;s/{{http_server_port}}/"'${FluentBitHttpPort}'"/;s/{{read_from_head}}/"'${FluentBitReadFromHead}'"/;s/{{read_from_tail}}/"'${FluentBitReadFromTail}'"/' | kubectl apply -f -

# マネジメントコンソールでCloudWatchを開
# インサイト Container Insightsを開く
# パフォーマンスのモニタリングで、計算資源使用量を確認できる
```

- アラームを設定する
- CPU使用率- 3点をクリック-メトリクスで表示
- ベルマークをクリック
- 条件
  - 静的
  - より大きいい
  - 80%
- 次へ
- 通知先
  - アラーム状態
  - 新しいトピック
  - トピック名: container-insights-alarm
  - メールエンドポイント：適当なやつ
  - トピックを作成
  - 作成したやつを通知先として設定
- アラーム名：nginx-pod-cpu

- CloudWatchを開く
- ログーロググループを開く
- application - nginxを開く

# Webapp

- Nodeをインストール
- setup
```bash
npm init -y
npm install express --save
node app.js
# http://localhost:3000/を開く
```

# コンテナイメージを作成

- コンテナを扱うには、Dockerを利用するのが手軽
- 開発者はDockerを使い、コンテナイメージを作成し、AWS ECRにイメージをpushする
- EKSは、ECRからコンテナイメージをPullして、コンテナを起動する

- docker
```bash
docker build -t node-web-app:latest .ddd
docker images
docker run -d -p 3000:3000 node-web-app:latest
# http://localhost:3000/を開く
docker ps
docker stop agitated_lichterman
docker ps
```

# コンテナイメージをEKSで起動

- `[AWSカウントID].dkr.ecr.[リージョン名].amazonaws.com/[ECRリポジトリ名]:[任意の識別子]`
```bash
aws sts get-caller-identity
docker build -t 786810205225.dkr.ecr.ap-northeast-1.amazonaws.com/node-web-app:0.0.1 .
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin 786810205225.dkr.ecr.ap-northeast-1.amazonaws.com
aws ecr create-repository --repository-name node-web-app --region ap-northeast-1
docker push 786810205225.dkr.ecr.ap-northeast-1.amazonaws.com/node-web-app:0.0.1
kubectl create deployment node-web-app --image 786810205225.dkr.ecr.ap-northeast-1.amazonaws.com/node-web-app:0.0.1 -o yaml --dry-run=client > node-web-app.yaml
# node-web-app.yamlを編集
#   creationTimestamp2行とstatusを削除
kubectl apply -f node-web-app.yaml
kubectl get pods -w
kubectl port-forward node-web-app-b66547f77-6n9tp 3000:3000
# http://localhost:3000/を開く
```


# ユーザ管理を行う
- EKSにおけるユーザ管理
  - EKSにおいては、AWSの認証だけでなく、Kubernetesの認証も必要になる
  - EKSのリソースを作成したIAMユーザやIAMロールには、デフォルトでKubernetes上の管理者権限を付与させる
  - 他のIAMユーザやIAMロールにKubernetesの権限を与えるには、別途操作が必要になる

- iAMからユーザを作成
  - ユーザ名:subyoshi
  - AWSマネジメントコンソールアクセス許可
  - IAMユーザを作成
  - 既存のポリシーを直接アタッチ
    - AdministratorAccess
  - ユーザを作成
- アクセスキーを取得
  - CLI
```bash
aws configure --profile subyoshi
AWS Access Key ID [None]:
AWS Secret Access Key [None]:
Default region name [None]: ap-northeast-1
Default output format [None]: json
```

- ユーザ認証を行うIAMユーザを作成
```bash
ls ~/.kube/config
mv ~/.kube/config ~/.kube/config.bak
kubectl get pods
aws --profile subyoshi eks --region ap-northeast-1 update-kubeconfig --name eks-study-cluster
kubectl get pods # EKSにアクセスできない
aws eks --region ap-northeast-1 update-kubeconfig --name eks-study-cluster
kubectl get pods # EKSにアクセスできる
aws iam list-users
eksctl create iamidentitymapping --cluster eks-study-cluster --arn arn:aws:iam::786810205225:user/subyoshi --group system:masters --username subyoshi
```

- 新しいユーザでKubernetesにアクセス
```bash
rm ~/.kube/config
kubectl get pods # アクセスできない
aws --profile subyoshi eks --region ap-northeast-1 update-kubeconfig --name eks-study-cluster
kubectl get pods # EKSにアクセスできる
mv ~/.kube/config.bak ~/.kube/config
```


# EKSにおけるVPCについて
- VPCはAWS上で仮想的にネットワークを構築するためのリソース
- EKSでは、VPCを設定することが前提となる
- eksctlでは自動的にVPCが作成されている
- EKSで利用するVPCには、EKS特有の設定が必要となる

- EKSでのVPCの要件
  - 異なるAzに２つ以上の同じ種類のサブネットがある
  - パブリックサブネットに対して、パブリックIPを自動割り当てする
  - パブリックサブネットのタグに`kubernetes.io/role/elb=1`を付与する
  - プライベートサブネットのタグに`kubernetes.io/role/internal-elb=1`を付与する

## VPCを作成する
- Elastic IPを割り当てる
- VPCを作成
  - VPCのみ
  - VPC名：eks-study
  - ap-northeast-1a public subnet: eks-study-public-1a
  - ap-northeast-1a private subnet: eks-study-private-1a
  - ap-northeast-1c public subnet: eks-study-public-1c
    - NATからIGWに変更
  - ap-northeast-1c private subnet: eks-study-private-1c
  - NAT GW: Elastic IPを指定
  - Public SubnetにパブリックIPアドレスの自動割り当てを有効化を設定
- タグ付け
  - パブリックサブネットのタグに`kubernetes.io/role/elb=1`を付与する
  - プライベートサブネットのタグに`kubernetes.io/role/internal-elb=1`を付与する

## 既存VPCでEKSを作成

```bash
eksctl delete cluster -f cluster_v3.yaml --disable-nodegroup-eviction
eksctl get cluster
eksctl create cluster -f cluster_v5.yaml
# EC2を確認すると、Subnetが設定されている
kubectl get node
kubectl create deployment nginx --image nginx:latest
kubectl get pods # PrivateSubnetにアサインされてるので、公開されない
# NAT GW、ElasticIPを削除(課金対象なので)
```

# EKSのKubernetesのバージョンアップデート

- Kubernetesでは、3-4か月に位階の頻度でマイナーバージョンがアップデートされる。
  - EKSにおいても同様である
  - EKSの利用者はバージョンに追従するために定期的にアップデートを行う必要がある
- EKSをアップデートするには、クラスタとノードをそれぞれアップデートする
- EKSでは、インプレースアップデートによるマイナーバージョンずつをアップデートする方法がサポートされている

## PodDisruptionBudget
- アップデートなどで意図的にノードを終了させる際に、最低限起動しておくべきPodの数を保証できる機能
- インプレースアップデートによる一時的なダウンの影響を極力抑える

```bash
kubectl scale deployment cluster-autoscaler -n kube-system --replicas 0
# 2つのノードを立てる
eksctl scale nodegroup --cluster eks-study-cluster --nodes 2 --name eks-study-ng
kubectl get node
# nginxのPodを冗長化する、２つにする
kubectl scale deployment nginx --replicas 2
kubectl get pods
# PodDisruptionBudget作成のためのyamlを作成
kubectl create poddisruptionbudget --dry-run=client -o yaml nginx --selector "app=nginx" --min-available 1 > nginx-pdb.yaml
kubectl apply -f nginx-pdb.yaml
```

## EKSアップデート


```bash
# クラスタアップデート20分ほど
eksctl upgrade cluster --name eks-study-cluster --approve
# ノードをアップデート
eksctl utils update-aws-node --cluster eks-study-cluster --approve
# アドオンのプログラムをアップデート
eksctl utils update-coredns --cluster eks-study-cluster --approve
eksctl utils update-kube-proxy --cluster eks-study-cluster --approve
kubectk apply -f cluster-autoscaler-autodiscover.yaml
# ノードグループのアップデート
eksctl create nodegroup -f cluster_v7.yaml
# 古いノードグループを削除
eksctl delete nodegroup -f cluster_v6.yaml --only-missing --approve
# autoscalerを元に戻す
kubectl scale deployment cluster-autoscaler --replicas 1 -n kube-system
# autoscalerが復活している
kubectl get deployments.apps -n kube-system
# バージョン確認
kubectl version --short
kubectl get node
```
