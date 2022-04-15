---
title: "KubernetesでWebアプリを作成する"
---

# システム構成図

- minikube中に「3層アプリケーション」を構築。
- 完成時には20以上のリソースが展開される。
- 構築順序
  - DB
  - AP
  - Web
  - L7ロードバランサ

![システム構成図](/images/books/docker-kubernetes-memorandum/system-diagram.png)

# ネットワーク構成図

- Ingress以外は直接アクセスできないクラスタネットワーク。
  
![ネットワーク構成図](/images/books/docker-kubernetes-memorandum/network-diagram.png)

# デバッグ用コンテナを作成するフロー

- ベースイメージ
  - CentOS
- 構築フロー
  - インストールに必要なファイルをコピー
  - 必要なモジュールをインストール
    - MongoDBシェル、ツール
    - ip、jq、curl
    - 不要なファイルを削除
- 実行コマンド
  - なし 

- 作業手順
  - Docker
    - Dockerで作成したイメージを実行
      - [Install MongoDB Community Edition on Red Hat or CentOS](https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-red-hat/)でMongoDBのリポジトリを取得
      - `docker build -t debug . `
      - `docker image ls`
    - 実行中コンテナに入る
      - `docker run -it debug sh `
    - 必要なコマンドが実行可能なことを確認
      - `ifconfig`
      - `jq`
      - `curl`
      - `mongo`
      - `docker container prune`
  - Kubernetes
    - Podを作成
      - `imagePullPolicy: Never`
        - を指定すると、ローカルDockerイメージを探す
      - `kubectl apply -f debug-pod.yml`
      - `kubectl get pod`
      - `kubectl exec -it pod/debug sh`
      - `kubectl delete -f debug-pod.yml`


# DBサーバのイメージ作成
- データベースはステートフル
  - 「初回起動」と「2回目以降の起動」で動作切り替えが必要
    - 「初回起動」
      - 初期化処理が必要
    - 「2回目以降の起動」
      - 初期化処理は不要
  - MongoDBを実行するイメージファイルの作成フロー
    - ベースイメージ
      - AlpineLinux
    - 構築フロー
      - 1. 起動時に実行するシェルをコピー
      - 2. ユーザ追加
      - 3. MongoDBをインストール
      - 4. データ保存用ディレクトリを作成
      - 5. 所有権の変更
      - 6. マウントポイントを設定
      - 7. 27017ポートを公開
  - 実行コマンド
    - ENTRYPOINT
      - 起動時に実行シェル
    - CMD
      - mongod

- 作業手順
  - 1. Dockerで作成したイメージを実行
    - `.dockerignore`で`COPY`しないファイルを選択
  - 2. 実行中コンテナに入る
    - `docker build -t weblog-db:v1.0.0 . `
    - `docker image ls`
    - `docker run -d weblog-db:v1.0.0 `
    - `docker container ls`
  - 3. MongoDBに接続できることを確認      
    - `docker exec -it focused_easley sh`
    - `mongo`
    - `show dbs;`
    - `exit`
    - `exit`
    - `docker stop focused_easley `
    - `docker system prune`

# DBサーバ構築 (ストレージ)

- ホストに保存する
  - spec.hostPathに保存先パスを指定
- NFSに保存する
  - spec.nfsにサーバと保存先パスを指定

- PersistentVolumeとPersistentVolumeClaimのペアを作成。
  - PVでは
    - storageClassName
    - capacity
    - accessMode
    - hostPath
    - の4つを指定
  - PVCでは、
    - storageClassName PVと同じ
    - accessMode PVと同じ
    - resources 
    - の３つを指定
    
- 構築手順
  - `mkdir -p /data/storage`
  - `kubectl apply -f weblog-db-storage.yml`
  - `kubectl get pv,pvc`
  - `kubectl delete -f weblog-db-storage.yml`

# DBサーバ構築 (Pod)

- mongoDBとは
  - NoSQLデータベース
  
|特徴|項目|詳細|
|:---:|:---:|:---:|
|データ構造|ドキュメント型|JSON構造でデータを保存|
|データ構造|スキーマレス|事前定義不要で動的スキーマ変更が可能|
|クエリ|集約|集計演算をサポート|
|性能|インデックス|RDBと同じインデックスをサポート|
|可用性|レプリケーション|クラスタをDBMSでサポート|
|可用性|シャーディング|水平展開をDBMSでサポート|


- 構築手順
  - マニフェストファイルを作成
    - PodにPVCを指定して(volumeMounts)、ストレージを接続
  - `mkdir -p /data/storage`
  - `kubectl apply -f weblog-db-storage.yml`
  - `kubectl get pod,pv,pvc`
  - `ls /data/storage`
  - `kubectl exec -it mongodb sh`
  - `mongo`
  - `show dbs;`
  - `exit`
  - `exit`
  - `kubectl delete -f weblog-db-storage.yml`

# DBサーバ構築 (Pod+Secret)

- keyfile
  - MongoDBクラスタ間で暗号化通信するためのキー情報
  - keyfileはクラスタ間で共有
  - ランダム文字列を使用する
- ランダム文字列生成
  - OpenSSLを使用すると、ランダム文字列生成が可能。
    - `openssl rand -base64 <文字数>`
  - 改行削除
    - `tr -d '\r\n'`
  - 必要サイズにカット
    - `cut -c 1-<文字列>`
- Secretを作成して、Podに接続

- 構築手順
  - 1. keyfileを作成
    - `openssl rand -base64 1024 | tr -d '\r\n' | cut -c 1-1024 > keyfile`
  - 2. Secretリソースを作成
    ```bash
    kubectl create secret generic mongo-secret \
      --from-literal=root_username=admin \
      --from-literal=root_password=Passw0rd \
      --from-file=./keyfile
    ```
  - 3. SecretリソースのYAMLを取得
    - `kubectl get secret/mongo-secret -o yaml`
  - 4. weblog-db-pod.ymlへマージ
    - labelsも追加する
  - 5. Secretリソースを削除
    - `kubectl delete secret/mongo-secret`
  - 6. PodにSecetリソースを紐づけ
    - キーバリューの場合
    ```bash
    spec:
    containers:
    - env:
      - name: "MONGO_INITDB_ROOT_USERNAME"
        valueFrom:
          secretKeyRef:
            name: mongo-secret
            key: root_username
    ```
    - キーファイルの場合
    ```bash
    spec:
      volumes:
      - name: secret
        secret:
          secretName: mongo-secret
          items:
          - key: keyfile
            path: keyfile
            mode: 0700
    ```

- シナリオ
  - 1. PV,Pod,Secretを作成
    - `ls /data/storage`
    - `rm -rf /data/storage/*`
    - `kubectl apply -f weblog-db-pod.yml`
  - 2. 作成したPodへ入る
    -  `kubectl get pod`
    - `ls /data/storage`
    - `kubectl exec -it mongodb sh`
  - 3. MongoDBへ接続
    - `mongo`
    - `show dbs;`
  - 4. 設定したユーザ名・パスワードで認証
    - `use admin;`
    - `db.auth("admin", "Passw0rd");`
  - 5. DB一覧を表示
    - `show dbs;`
    - `exit`
    - `exit`
    - `kubectl delete -f weblog-db-pod.yml`

# DBサーバ構築 (StatefulSet)

- レプリケーションとは？
  - データベースを冗長化させる仕組み
  - プライマリDB: 読み書き可能
  - セカンダリDB: 読み取り専用

- シナリオ
  - 1. PersistentVolume, Secret, StatefulSetを作成
    - `ls /data/storage`
    - `rm -rf /data/storage/*`
    - `mkdir /data/pv0000 /data/pv0001 /data/pv0002`
    - `kubectl apply -f weblog-db-statefulset.yml`
  - 2. 作成したPodへ入る
    -  `kubectl get pod`
    - `ls /data/storage`
    - `kubectl exec -it mongo-0 sh`
  - 3. MongoDBへ接続
    - `mongo`
    - `show dbs;`
  - 4. 設定したユーザ名・パスワードで認証
    - `use admin;`
    - `db.auth("admin", "Passw0rd");`
  - 5. DB一覧を表示
    - `exit`
    - `exit`
    - `kubectl delete -f weblog-db-statefuleset.yml`
    - `kubectl get pvc,pv`
    - `kubectl delete persistentvolumeclaim/storage-mongo-0 persistentvolumeclaim/storage-mongo-1  persistentvolumeclaim/storage-mongo-2 persistentvolume/storage-volume-0 persistentvolume/storage-volume-1  persistentvolume/storage-volume-2 `

# DBサーバ構築 (Headless Service)

- レプリカセットの初期化
  - `rs.initiate()`メソッドで初期化する
```bash
rs.initiate({
  _id: "rs0",  # レプリカセット名を指定
  members: [ # レプリケーションするサーバ一覧を指定
    { _id: 0, host: "mongo-0.db-svc:27017" },
    { _id: 1, host: "mongo-1.db-svc:27017" },
    { _id: 2, host: "mongo-2.db-svc:27017" }
  ]
})
```

- Headless Serviceを作成
  - Serviceの一種。
  - StatefulSetと組み合わせることでPodを名前で特定できる

- シナリオ
  - 1. PersitentVolume, Secret, StatefuleSet, Serviceを作成
    - `rm -rf /data/pv0000 /data/pv0001 /data/pv0002`
    - `mkdir /data/pv0000 /data/pv0001 /data/pv0002`
    - `kubectl apply -f weblog-db-fullset.yml`
  - 2. 作成したPodへ入る
    - `kubectl get pod`
    - `ls /data/storage`
    - `kubectl exec -it mongo-0 sh`
    - `ping mongo-1.db-svc`　
      - 別のDBサーバは、Pod名+HeadlessService名で名前解決できる
  - 3. MongoDBを初期化
    - `use admin;`
    - `db.auth("admin", "Passw0rd");`
    - 初期化
```bash
rs.initiate({
  _id: "rs0",  
  members: [
    { _id: 0, host: "mongo-0.db-svc:27017" },
    { _id: 1, host: "mongo-1.db-svc:27017" },
    { _id: 2, host: "mongo-2.db-svc:27017" }
  ]
});
```
  - 4. レプリカセットが構築できているか確認
    - `rs.status();`
    - `show dbs;`
    - `exit`
    - `exit`

# DBサーバの初期化

- 0. 前提条件
  - DBサーバの関連のPodが起動していること
  - レプリカセットの初期化まで完了していること
- 1. ユーザ作成
- 2. 初期データ作成

- 初期化手順
  - 1. デバッグ用Podを起動
    - `kubectl apply -f debug-pod.yml`
  - 2. 初期化スクリプトをデバッグ用Podへコピー
    - `kubectl get pod`
    - `kubectl cp . debug:/root/init-db/`
  - 3. デバッグ用Podに入る
    - `kubectl exec -it debug sh`
  - 4. MongoDBへ接続してプライマリを確認して切断
    - `mongo mongo-0.db-svc`
    - `use admin;`
    - `db.auth("admin", "Passw0rd");`
  - 5. 初期化スクリプトを修正 (必要であれば)
  - 6. 初期化スクリプトを実行
    - `sh init.sh`
  - 7. いずれかのMongoDBに接続してデータが入ったことを確認
    - `use admin;`
    - `db.auth("admin", "Passw0rd");`
    - `show dbs;`
    - `use weblog;`
    - `show collections;`
    - `db.posts.find().pretty();`
