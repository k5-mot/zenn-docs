---
title: "Kubernetesリソースの備忘録"
---

# Pod

- Podとは、
  - Kubernetesの最小単位。
  - 同一環境で動作するDockerコンテナの集合
  - 1つのPodに複数のDockerコンテナを入れられる
- マニフェストファイル
  - 主要なspecは、containersとvolumes。
  - spec
    - containers
      - name: コンテナ名を指定
      - image: イメージ名を指定 (タグもきちんと設定する)
      - imagePullPolicy: イメージ取得方法を指定
        - Always: 毎回リポジトリからダウンロードを行う。
        - Never: ローカルのイメージを利用。
        - IfNotPresent: ローカルに存在すればローカルを利用し、存在しなければリポジトリからダウンロードする。
      - command: コンテナへ引き渡すENTRYPOINTのコマンドを指定
      - args: コンテナへ引き渡すCMDのコマンドを指定
      - env: コンテナへ引き渡す環境変数を設定
      - volumeMounts: コンテナへマウントするストレージを指定
        - spec.volumes.nameに一致させる
    - volumes: マウントしたいストレージ先は状況に応じて選択
    - ボリューム名とデータ保存先に分かれる
      - name: ストレージ名を指定 
        - spec.containers.volumeMounts.nameに一致させる
      - 以下のデータ保存先から選ぶ
      - hostPath: 保存先がPod実行サーバのフォルダ
        - path: パス
        - type: 種別
          - Directory: 存在するディレクトリ
          - DirectoryOrCreate: ディレクトリが存在しなければ作成
          - File: 存在するファイル
          - FileOrCreate: ファイルが存在しなければ作成
      - nfs: 保存先がNFSサーバのフォルダ
        - server: 
        - path: 
      - configMap: Kubernetes ConfigMapリソースをファイルとしてマウントさせる
        - name:
        - items:
          - key:
          - path: keyとpathは同名にするのがおすすめ
      - secret: Secretリソースをファイルとしてマウントさせる
        - secretName:
        - items:
          - key:
          - path
      - emptyDir: 一時的な空フォルダ

- 以下、ハンズオン
```bash
# 1. ホストにフォルダ、ファイルを作成
mkdir -p /data/storage
ls /data
echo "Hello" > /data/storage/message.txt
ls /data/storage/message.txt
# 2. 作成したディレクトリをマウントしたPodマニフェストファイルを作成
# 3. リソース作成
kubectl apply -f pod.yml 
kubectl get pod
kubectl exec -it pod/sample sh
cd /home/nginx
cat message.txt
exit
kubectl delete -f pod.yml
```

# ReplicaSet

- ReplicaSetとは？
  - Podの集合。
  - Podをスケールできる。
- マニフェストファイル
  - spec
    - replicas: Podを複製する数を指定
      - 値を変更することでスケールアウトやスケールインができる
    - selector: 複製するPod数を数えるために使うラベルを指定
      - テンプレートとして含めるPodのmetadata.labelsに一致させる
    - template: 複製するPodのマニフェストを指定
      - 中身はPodと同じ

- 以下、ハンズオン
```bash
# 1. ReplicaSetマニフェストファイルを作成
# 2. リソース作成
kubectl apply -f replicaset.yml 
kubectl get all
# 3. 手動スケールアウト
# replicasを2 → 3に変更
kubectl apply -f replicaset.yml 
kubectl delete -f replicaset.yml 
```

# Deployment

- Deploymentとは？
  - ReplicaSetの集合。
  - ReplicaSetの世代管理ができる
- マニフェストファイル
  - 主要なspec
    - replicas
    - selector
    - revisionHistoryLimit：ReplicaSetの履歴保存数を指定
      - デフォルトは10
    - strategy：デプロイ方法を指定
      - rollingUpdate：ローリングアップデート(デフォルト値)
        - maxSurge；レプリカ数を超えてよいPod suu 
        - maxUnavailable：一度に消失してよいPod数
    - template

- 以下、コマンド例
```bash
# ロールアウト履歴を表示します
#   TYPE: リソース種別
#   NAME: リソース名
kubectl rollout history TYPE/NAME
# ロールバックする
#   TYPE: リソース種別
#   NAME: リソース名
#   --to-revision=N: 指定されたリビジョンに戻す(デフォルト値は0(直前の履歴)。)
kubectl rollout undo TYPE/NAME --to-revision=N
```

- 以下、ハンズオン
```bash
# 1. Deploymentマニフェストを作成
# 2. リソース作成
kubectl apply -f deployment.yml
kubectl get all
# 3. ロールアウト履歴確認
kubectl rollout history deploy/nginx
# 4. Deployment修正
    spec:
      containers:
      - name: nginx
-        image: nginx:1.17.2-alpine
+        image: nginx:1.17.3-alpine
# 5. ロールアウト履歴確認
kubectl apply -f deployment.yml
kubectl rollout history deploy/nginx
kubectl get all
# 6. ロールバック
kubectl rollout undo deploy/nginx
kubectl delete -f deployment.yml 
```

# Service

- Serviceとは？
  - 外部公開、名前解決、L4ロードバランサー
  - ４つの種別
    - ClusterIP
      - クラスタネットワーク内にIPアドレス公開。
      - 名前指定でPodへ到達できるようにする。
    - NodePort
      - ClusterIpに加え、Nodeのポートにポートマッピングして受け付けられるようにする。
    - LoadBalancer
      - NodePortに加え、クラウドプロバイダーのロードバランサを利用してサービス公開する。
    - ExternalName
      - 外部サービスに接続。
- マニフェストファイル
  - spec
    - type: ClusterIP, NodePort, LoadBalancer, ExternalName
    - clusterIP: ClusterIPのとき、クラスタネットワーク内のIPアドレスを指定。
      - None: HeadlessService。StatefulSetで使う。
      - "": 空文字の場合、自動採番
      - "<IPアドレス>": 指定されたIPアドレス
    - ports: 受付または転送先のポート番号を指定。
      - port: サービス受付ポート
      - targetPort: コンテナ転送先ポート
      - nodePort: ノード受付ポート (type: NodePortのみ)
    - selector: 転送先Podを特定するラベルを指定。
      - 以下例
        - app: sample
        - env: study

- 以下、ハンズオン
```bash
# 1. NodePortのServiceマニフェストを作成
# 2. リソース作成
kubectl apply -f service.yml
kubectl get all
# 3. ブラウザからアクセスして動作確認
# http://192.168.195.129:30000/をブラウザで開く
kubectl delete -f service.yml 
```

# ConfigMap

- ConfigMapとは？
  - Kubernetes上で利用する設定情報を管理するリソース
- マニフェストファイル
  - specではなく、dataにキーバリューで保存する。
  - data:
    - KEY: VALUE
- ConfigMapリソースの利用方法
  - 環境変数へ渡す  
    - spec.containers.env.valueFromにConfigMapを指定
    - 以下例
```yaml
spec:
  containers: 
  - name: sample
    image: nginx:1.17.2-alpine
    env:
    - name: TYPE
      valueFrom: 
        configMapKeyRef:
          name: sample-config # ConfigMapのリソース名
          key: type  # ConfigMapのリソース中の対象キー名
```
  - ファイルとしてマウント
    - spec.volumesとspec.containers.volumeMountsに指定
```yaml
spec:
  containers: 
  - name: sample
    image: nginx:1.17.2-alpine
    volumeMounts: # マウント先の指定
    - name: config-storage
      mountPath: /home/nginx
  volumes: # 接続するConfigMapを指定
  - name: config-storage # volumeMounts.nameと同じ名前を指定
    configMap:
      name: sample-config
      items:
      - key: sample.cfg
        path: sample.cfg
```

- 以下、ハンズオン
```bash
# 1. ConfigMapとPodを含むマニフェストファイル作成
# 2. リソース作成
kubectl apply -f configmap.yml
kubectl get all
# 3. Podに入ってConfigMapが接続されていることを確認
kubectl exec -it pod/sample sh
cat /home/nginx/sample.cfg # ファイルマウント
env # 環境変数
exit
kubectl delete -f configmap.yml 
```

# Secret 

- Secretとは？
  - Kubernetes上で利用する機微情報。データはBase64エンコードされる。
- マニフェストファイル
  - specではなく、dataにキーバリューで保存する。
  - data:
    - KEY: VALUE # VALUEはBase64エンコードされた文字列
- Secretリソースの作成方法
  - コマンドで直接生成
    - キーバリューは引数で複数指定
```bash
# 名称を指定してSecretを生成
#   引数
#     NAME Secretの名前を指定
#   オプション
#     --from=literal=key=value キーバリューを指定して作成
#     --from-file=filename ファイルから作成
kubectl create secret generic NAME [option]
```
  - マニフェストファイルから作成
    - マニフェストファイルから生成は`kubectl apply`
    - Base64文字列の取得が必要
```bash
# 指定した文字列のBase6変換後文字列を取得する
#   引数
#     TEXT Base64変換したい文字列
echo -n 'TEXT' | base64
```
- Secretリソースの利用方法
  - ConfigMapと同じ

- 以下、ハンズオン
```bash
# 1. SecretとPodを含むマニフェストファイル作成
# 2. リソース作成
kubectl apply -f secret.yml
kubectl get all
# 3. Podに入ってSecretが接続されていることを確認
kubectl exec -it pod/sample sh
cat /home/nginx/keyfile # ファイルマウント
env # 環境変数
exit
kubectl delete -f secret.yml 
```

# PersistentVolume, PersistentVolumeClaim

- PersistentVolume(PV)とは？
  - 永続データの実態。
  - ストレージへの接続情報。ストレージを抽象化。
- PersistentVolumeClaim(PVC)とは？
  - 永続データの要求。
  - PVC → PV → Storage
- PVのマニフェストファイル
  - ストレージを抽象化定義する3プロパティ
    - storageClassName: ストレージの名前を定義
    - accessModes: 読み書きの定義
      - ReadWriteOnce
      - ReadOnlyMany
      - ReadWriteMany
    - capacity: ストレージ容量の定義
  - 削除時動作を定義するプロパティ
    - persistentVolumeReclaimPolicy: PVC削除後にPVが同動作するのかの定義
      - Retain: PVCが消えてもPVを残す
      - Delete: PVCが消えたらPVも消す
      - Recycle: (非推奨) 対象ボリューム内データを削除して再利用
  - 保存先を定義するプロパティ
    - hostPath: ホスト上に保存する場合はhostPath
      - path: 保存先のパスを指定
      - type:
        - Directory: 存在するディレクトリ
        - DirectoryOrCreate: ディレクトリが存在しなければ作成
        - File: 存在するファイル
        - FileOrCreate: ファイルが存在しなければ作成
- PVCのマニフェストファイル
  - ストレージを抽象化定義する3プロパティ
    - storageClassName: ストレージの名前を定義
    - accessModes: 読み書きの定義
    - resources: 
      - requests:
        - storage: 1Gi

- 以下、ハンズオン
```bash
# 1. PVとPVCを含むマニフェストファイル作成
# 2. リソース作成
mkdir /data/storage
kubectl apply -f storage.yml
kubectl get pvc,pv
kubectl delete -f storage.yml 
```

# StatefulSet

- StatefulSetとは？
  - Podの集合。
  - podをスケールする際の名前が一定。
- StatefulSetのマニフェストファイル
  - Deploymentとほぼ同じ
```bash
spec: 
  updateStrategy: # strategyではなく、updateStrategy
    type: RollingUpdate
  serviceName: frontend # HeadlessServiceを指定
  template: # Podのテンプレートを定義
    ...
  volumeClaimTemplates: # PVCのテンプレートを定義
    ...
```

- 以下、ハンズオン
```bash
# 1. StatefulSetおよびServiceのマニフェストファイル作成
kubectl apply -f statefulset.yml
kubectl get all
# 2. デバッグ用PodからService経由でPodにアクセス
kubectl run debug --image=centos:7 -it --rm --restart=Never -- sh
curl http://nginx-0.sample-svc
exit 
kubectl delete -f statefulset.yml 
```

# Ingress

- Ingressとは？
  - 外部公開、L7ロードバランサー
  - URLでサービスを切り替えられる
- Ingressのマニフェストファイル
```yaml
spec: 
  rules:
  - http:
      paths:
      - path: / # pathにURLを指定
        backend: # backendに転送先のサービスを指定
          serviceName: web-svc
          servicePort: 80
```

- 以下、ハンズオン
```bash
# 1. Deployment, Serviceを準備
# 2. Ingressを作成
kubectl apply -f ingress.yml
kubectl get ing,svc,deploy
# 3. 外部からアクセス
# ingressのADDRESS欄にあるIPをブラウザで開く
kubectl delete -f ingress.yml 
```
```bash
# Troubleshooting
minikube addons enable ingress
```
