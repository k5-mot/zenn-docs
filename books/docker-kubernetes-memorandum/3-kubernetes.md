---
title: "Kubernetes備忘録"
---

# Hello, World!

- "hello-world"イメージをk8s上で実行・確認・削除する
```bash
# 実行
kubectl run hello-world --image hello-world --restart=Never
# 確認
kubectl get pod
# ログを確認
kubectl logs pod/hello-world
# 削除
kubectl delete pod/hello-world


```
:::message alert
`minikube start --vm-driver=none`を、起動時に実行すること!!!
:::

:::message alert
この時点で、"hello-world"を実行できない場合、以下のトラブルシューティングを試すこと!!!

1. kubeletを再起動する
```bash
systemctl restart kubelet
```
2. swapを無効化する
```bash
swapoff -a
vi /etc/fstab
```
```diff:/etc/fstab
# /etc/fstab
- /dev/mapper/cl-swap
+ # /dev/mapper/cl-swap
```
```bash
minikube delete 
minikube start --vm-driver=none
```
3. taintsの設定を削除する
```bash
kubectl uncordon localhost.localdomain
```
:::

# Kubernetesとは？

- Kubernetesとは、コンテナオーケストレーション
  - 物理リソースに対して、大量のコンテナをデプロイ・管理していく仕組み。
- システム運用で困っていたことが解決できる 
  - システムリソースの利用率に無駄がある
    - 複数コンテナの共存
  - 突発的な大量アクセスでシステムが応答しなくなった
    - 水平スケール
  - 突然、一部システムがダウンした
    - 監視&自動デプロイ
  - リリースの度にサービス停止が発生する
    - ローリングデプロイ
- 読み方は、「くーばーねぃてぃす」
- どんな仕組み？
  - 使えるリソースを一元管理
  - 各リソースサーバをWorker node
  - 管理するサーバをMaster nodeという
    - kubectlはmaster nodeに指示出しし、master nodeはworker nodeに指示だしする

# Kubernetesリソースとは？

- 主なリソース(4分類10種類)
  - ワークロード
    - Pod
      - 最小単位。Dockerコンテナの集合
    - ReplicaSet
      - Podの集合。Podをスケールできる。
    - Deployment
      - ReplicaSetの集合。ReplicaSetの世代管理ができる
      - ロールバックとかロールフォワードとか
    - StatefulSet
      - Podの集合。Podをスケールする際の名前が一定
  - サービス
    - Service
      - 外部公開、名前公開、L4ロードバランサー
    - Ingress
      - 外部公開、L7ロードバランサー
  - 設定
    - ConfigMap
      - 設定情報。
    - Secret
      - 機微情報(Base64エンコードされている)
  - ストレージ
    - PersistentVolume
      - 永続データの実態
      - ストレージへの接続情報。ストレージを抽象化
    - PersistentVolumeClaim
      - 永続データの要求
      - 抽象化されたストレージを要求

# Kubernetesネットワークとは？

- NodeとPod
  - Nodeは実サーバに一致する
  - リソースは各ワーカーノードに分散配置される
- Kubernetesには、２つの異なるネットワークがある
  - クラスタネットワーク
    - クラスタネットワークへ外から直接アクセスはできない
  - 外部ネットワーク
    - 管理端末は外部ネットワークに接続
- コンテナにアクセスしたい場合
  - Master nodeに対して、kubectlを使い直接、コンテナにアクセスする
  - 踏み台のコンテナ経由で、コンテナにアクセスする
  - サービス経由で、コンテナにアクセスする

# Kubernetesの基本操作
## リソースの作成/確認/削除

- リソースの作成
  - 「定義作成」
    - マニフェストファイル(YAML)を作成
  - 「定義適用」
    - Kubernetesに反映
    - kubectlコマンドを利用して反映
- マニフェストファイル
  - YAMLファイルにリソースの定義を記載する
- リソース作成/変更コマンド
```bash
# マニフェストファイルを指定してリソースを作成/変更する
#   <filename>: マニフェストファイルのパス
kubectl apply -f <filename>
# 指定したリソースの状態を確認する
#   -f <filename>: マニフェストファイルのパス
#   TYPE: リソース種別(pod, replicasetなど)
kubectl get [-f <filename>] [Type]
# 指定したリソースを削除する
#   -f <filename>: マニフェストファイルのパス
#   TYPE/NAME
#   -o [wide/yaml]: 出力形式を指定する
#     wide: 追加情報の表示
#     yaml: YAML形式で表示
kubectl delete [-f <filename>] [TYPE/NAME] [-o [wide|yaml]]
```

```bash
# "hello-world"コンテナを含むPodを作成
kubectl apply -f pod.yml
# Podが起動していることを確認
kubectl get -f pod.yml 
kubectl get all
kubectl get pod
# Podを削除
kubectl delete -f pod.yml
```

## Secretリソースの登録
- Secretリソースに登録する秘密データは、手動で登録する
```bash
# 指定されたSecretを作成する
#   NAME: Secretリソース名
#   OPTIONS: オプション
#     --from-literal=KEY=VALUE キーバリューペアを指定して登録
#     --from-file=[KEY=]PATH ファイルを指定して登録
kubectl create secret generic NAME OPTIONS
```

## マニフェストファイル
- マニフェストファイル(YAML)にリソースの定義を記載する
- マニフェストファイルの構成
  - 種別(Kind)
    - kind: リソースの種別。Podとか。
    - apiVersion: kindによって定まる
  - メタデータ
    - name:
    - namespace:
      - Pod名は名前空間と合わせて一意にする
    - label:
      - ラベルは任意に設定できる
  - コンテナ定義
    - containers:
      - name: 
        - Podに含まれるコンテナ名を指定
      - image:
        - コンテナのイメージを指定するとき場バージョンも指定する
        - バージョン指定がない場合、latest指定となり思わぬ誤作動につながる

- nginxのpodを作成する
```bash
# nginxを含むPodのマニフェストファイル作成
# Kubernetesにリソース作成
kubectl apply -f pod.yml
# Podが起動していることを確認
kubectl get pod
# Podを削除
kubectl delete -f pod.yml
kubectl get pod
```

- spec:
  - containers:
    - name:
    - command: (DockerのENTRYPOINTと同義)
    - args: (DockerのCMDと同義)
    - env:
      - Kubernetesでは、環境変数でコンテナ設定を渡すケースが多い
  
```bash
# nginxを含むPodのマニフェストファイル作成
# Kubernetesにリソース作成
kubectl apply -f pod.yml
# Podが起動していることを確認
kubectl get pod
# Podが起動していることを確認(ウォッチ)
kubectl get pod -w
# Podを削除
kubectl delete -f pod.yml
kubectl get pod
```

## kindに応じたapiVersionの確認
- kindに応じたapiVersionの指定が必要
  - [Podの場合](https://kubernetes.io/docs/reference/kubernetes-api/workload-resources/pod-v1/)
  - `import "k8s.io/api/core/v1"`
    - coreの場合、省略できる
```yaml
# Podの場合
apiVersion: core/v1
kind: Pod
# Ingressの場合
apiVersion: networking.k8s.io/v1
kind: Ingress
```

### リソース名は省略できる
- 以下は例
- ワークロード
  - Pod = po
  - ReplicaSet = rs
  - Deployment = deploy
  - StatefulSet = sts
- サービス
  - Service = svc
  - Ingress = ing
- 設定
  - ConfigMap = cm
  - Secret = (省略名無し)

## Podに入ってコマンド実行

```bash
# 指定したPodに入ってシェル操作を行う
#   POD 中に入りたいPod名
kubectl exec -it POD sh
# プロセスを終了してコンテナからログアウト
exit
# プロセスを残したままコンテナからログアウト
[Ctrl + P] → [Ctrl + Q]
```

```bash
# CentOSとnginxを起動するマニフェストを作成
# CentOSとnginxのPodを起動
kubectl apply -f pods.yml
# PodのIPアドレスを確認
kubectl get pod -o wide
# 起動したCentOSコンテナ内に入る
kubectl exec -it debug sh
# nginxに対してcurlを実行
curl http://172.17.0.3 (nginxのIPアドレス)
# CentOSを出る
exit
[Ctrl + P] → [Ctrl + Q]
# CentOSとnginxのPodを削除
kubectl delete -f pods.yml
```

## Pod⇔ホスト間のファイル転送

- 以下、Pod ↔ ホスト間のファイル転送コマンド
```bash
# 指定されたファイルを指定された転送先に送る (ホスト → Pod)
#  src: 
#    転送元ファイル名/フォルダ名
#  pod-name: 
#    転送先のPod名
#  dst: 
#    転送先ファイル名/フォルダ名
kubectl cp <src> <pod-name>:<dst> 
# 指定されたファイルを指定された転送先に送る (Pod → ホスト)
#  pod-name: 
#    転送元のPod名
#  src: 
#    転送元ファイル名/フォルダ名
#  dst: 
#    転送先ファイル名/フォルダ名
kubectl cp <pod-name>:<src> <dst> 
```

- 以下、ハンズオン
```bash
kubectl apply -f pod.yml 
kubectl get pod
ls
# Host → Pod
kubectl cp sample.txt debug:/var/tmp/sample.txt
kubectl exec -it debug sh
ls /var/tmp/sample.txt 
cat /var/tmp/sample.txt 
# Pod → Host
cd ~
echo "Hello, Docker & Kubernetes!!!" > sample2.txt
exit 
kubectl get pod
kubectl cp debug:/root/sample2.txt ./sample
2.txt
cat sample2.txt
# 
kubectl delete -f pod.yml
```

## ログ確認

```bash
# 指定したリソースの状態(概況)を確認する
#   TYPE/NAME
#     リソース種別とリソース名を指定
kubectl describe [TYPE/NAME]
# 指定したリソースの状態(ログ)を確認する
#   TYPE/NAME
#     リソース種別とリソース名を指定
#   --tail=n
#     直近のnレコードだけ取得
kubectl logs [TYPE/NAME][--tail=n]
```

- 以下、ハンズオン
```bash
# 1. CentOSとnginxのPodを起動 (作成済のマニフェストを利用)
kubectl apply -f pods.yml 
# 2. CentOSとnginxの状態を確認
kubectl describe pod/debug
kubectl describe pod/nginx
kubectl get pod -o wide # debugのIPを控える
# 3. CentOSに入る
kubectl exec -it debug sh
# 4. curlでnginxにアクセス
curl http://172.17.0.4
# 5. CentOSから出る
exit
# 6. nginxのログを確認 (アクセスログが見れる)
kubectl logs pod/nginx
# 7. CentOSとnginxのPodを確認
kubectl delete -f pods.yml
```