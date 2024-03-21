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

# APサーバ構築 (イメージ作成)

- Pod間の依存関係
  - 「依存元が動作していない」を考慮する
    - 例: DBサーバが動作していない場合、APサーバはどう動作すべきか？
- 設計
  - Node.jsアプリケーションを実行するイメージファイルの作成フロー
    - ベースイメージ
      - Node.js v10 on AlpineLinux
    - 構築フロー
      - 1. 「Node.jsアプリケーション」と「起動シェル」をコピー
      - 2. 「起動シェル」はパスが通った場所へ移動、アクセス権変更
      - 3. 「Node.jsアプリケーション」の初期化
      - 4. カレントディレクトリを「Node.jsアプリケーション」フォルダへ変更
      - 5. 3000ポートを公開
    - 実行コマンド
      - ENTRYPOINT
        - 起動時に実行するシェル
      - CMD
        - npm start
- シナリオ
  - 1. MongoDBのプライマリを確認
  ```bash
  # APサーバがDBサーバより後に起動することを保証するシェルスクリプトの作成
  docker build -t weblog-app:v1.0.0 .
  kubectl get pod
  kubectl exec -it mongo-0 sh
  mongo
  use admin;
  db.auth("admin", "Passw0rd");
  exit
  exit
  kubectl get pod -o wide
  # マニフェストファイル、ServiceのnodePortはデフォルトでは、30000-32767を選択する
  ```
  - 2. MongoDBに対するService, Endpointsを作成
  ```bash
  kubectl apply -f weblog-db-service.yml
  ```
  - 3. Dockerで作成したイメージを実行
  ```bash
  ifconfig
  docker run \
    -e MONGODB_USERNAME="user" \
    -e MONGODB_PASSWORD="welcome" \
    -e MONGODB_HOSTS="192.168.195.129:32717" \
    -e MONGODB_DATABASE="weblog" \
    -d  \
    -p 8080:3000 \
    weblog-app:v1.0.0
  ```
  - 4. 作成したNode.jsアプリケーションコンテナへ接続
  ```bash
  # ブラウザでhttp://192.168.195.129:8080/を開く
  curl
  ```
  - 5. MongoDB接続用Service, ENdpointsを削除
  ```bash
  docker container ls
  docker stop sharp_elion
  docker container prune
  kubectl delete -f weblog-db-service.yml
  # Service削除時にEndpointsも削除されるため、２重削除でエラーになる
  kubectl get svc,ep
  ```


# APサーバの構築(Pod+Secret)

- DBサーバで作成したSecretリソースを再利用する
- Base64文字列の取得
  - `echo -n "<文字列>" | base64`
- DBサーバ共用のSecretを利用する単一Podを作成
- シナリオ
  - 1. Secret,podを作成
  ```bash
  kubectl apply -f weblog-app-pod.yml 
  kubectl get pod
  kubectl get pod -o wide
  ```
  - 2. デバッグPodを作成して入る
  ```bash
  kubectl exec -it debug sh
  ```
  - 3. ApサーバPodへ接続確認
  ```bash
  curl 172.17.0.8:3000
  kubectl delete pod/nodeapp
  ```  

# APサーバの構築(Deployment)

- 前提
  - DBサーバが起動して、初期化まで済んでいること
- シナリオ
  - 1. Secret,Deploymentを作成
  ```bash
  kubectl apply -f weblog-app-pod.yml 
  kubectl get pod
  kubectl get pod -o wide
  ```
  - 2. デバッグPodを作成して入る
  ```bash
  kubectl exec -it debug sh
  ```
  - 3. ApサーバPodへ接続確認
  ```bash
  curl 172.17.0.9:3000
  curl 172.17.0.8:3000
  curl 172.17.0.10:3000
  exit
  kubectl delete deploy/nodeapp
  ```  

  # APサーバ構築(Service)

- 設計
  - Serviceを作成
- 前提
  - DBサーバが起動して、初期化まで済んでいること
- シナリオ
  - 1. Secret,Deployment,Serviceを作成
  ```bash
  kubectl apply -f weblog-app-fullset.yml 
  kubectl get pod
  ```
  - 2. デバッグPodを作成して入る
  ```bash
  kubectl exec -it debug sh
  ```
  - 3. ApサーバPodへService経由で接続
  ```bash
  curl http://app-svc:3000/
  exit
  ```  
  - 4. APサーバのいずれかにログ出力されていることを確認
  ```bash
  kubectl get pod
  kubectl logs pod/nodeapp-69bbf7b46-kk2kb
  ```


# WEBサーバのイメージ作成

- Nginxの設定に環境変数を利用する方法
  - envsubstを利用して、nginx.confの値を環境変数で上書きする。
  ```bash
  # envsubstを利用して、nginx.confの値を環境変数で上書きする
  #   引数
  #     $$環境変数
  #       利用する環境変数を指定。複数ある場合は、空白つなぎ。
  #     入力
  #       入力とするテンプレート設定ファイル
  #     出力
  #       出力とする設定ファイル
  #   戻り値
  #     なし
  envsubst "$$環境変数" < "入力" > "出力"
  ```
- 設計
  - ベースイメージ
    - Nginx v1.17 on Alpine
  - 構築フロー
    - 1. nginx.confと起動シェルスクリプトのコピー
    - 2. 起動シェルスクリプトを移動、権限変更
  - 実行コマンド
    - ENTRYPOINT
      - 起動時に実行するシェル
    - CMD
      - nginx -g daemon off;
- 前提
  - DB/APサーバが起動して、初期化まで済んでいること
- シナリオ
  - 1. APサーバへアクセスするServiceを作成
  ```bash
  docker build -t weblog-web:v1.0.0 .
  kubectl apply -f weblog-app-service.yml 
  kubectl get pod
  ```
  - 2. Webサーバコンテナ起動
  ```bash
  docker run \
    -e APPLICATION_HOST=192.168.195.129:30000 \
    -p 8080:80 \
    -d \
    weblog-web:v1.0.0 
  ```
  - 3. 外部からブラウザでアクセスして画面確認
  ```bash
  # http://192.168.195.129:8080をブラウザを開く
  docker container ls
  docker stop infallible_colden
  docker container prune
  kubectl delete -f weblog-app-service.yml 
  ```

# WEBサーバ構築(Pod)

- 設計
  - 単一Podを作成
- 前提
  - DB/APサーバが起動して、初期化まで済んでいること
- シナリオ
  - 1. ConfigMap, Deployemnt, Serviceを作成
  ```bash
  kubectl apply -f weblog-web-pod.yml 
  ```
  - 2. 作成したWebサーバPodのIPアドレスを確認
  ```bash
  kubectl get pod -o wide
  ```
  - 3. デバッグPodを作成して入る
  ```bash
  kubectl exec -it debug sh 
  ```
  - 4. Webサーバへ接続
  ```bash
  curl http://172.17.0.11
  ```
  - 5. 接続したWebサーバにアクセスログがあることを確認
  ```bash
  kubectl get pod
  kubectl logs pod/nginx
  kubectl logs pod/nodeapp-69bbf7b46-vgf27
  kubectl delete -f weblog-web-pod.yml 
  ```

# WEBサーバ構築(Pod+ConfigMap)

- 設計
  - 単一PodにCOnfigMapを追加
- 前提
  - DB/APサーバが起動して、初期化まで済んでいること
- シナリオ
  - 1. ConfigMap, Podを作成
  ```bash
  kubectl apply -f weblog-web-pod+configmap.yml 
  kubectl get pod
  ```
  - 2. WebサーバPodに入って、ConfigMapを利用していることを確認
  ```bash
  kubectl exec -it nginx sh 
  cat /etc/nginx/nginx.conf
  exit
  ```
  - 3. WebサーバPodのIPアドレスを確認
  ```bash
  kubectl get pod -o wide
  ```
  - 4. デバッグPodを作成して入る
  ```bash
  kubectl exec -it debug sh 
  ```
  - 5. WebサーバPodへ接続確認
  ```bash
  curl http://172.17.0.11
  kubectl delete -f weblog-web-pod+configmap.yml
  ```


  # WEBサーバ構築(Deployment)

- 設計
  - 作成したPodを元に、Deploymentを作成
- 前提
  - DB/APサーバが起動して、初期化まで済んでいること
- シナリオ
  - 1. ConfigMap, Deploymentを作成
  ```bash
  kubectl apply -f weblog-web-deployment.yml 
  ```
  - 2. WebサーバPodのIPアドレスを確認
  ```bash
  kubectl get pod -o wide
  ```
  - 3. デバッグPodを作成して入る
  ```bash
  kubectl exec -it debug sh 
  ```
  - 4. WebサーバPodへ接続確認
  ```bash
  curl http://172.17.0.11
  curl http://172.17.0.13
  curl http://172.17.0.12
  kubectl delete -f weblog-web-deployment.yml
  ```

# WEBサーバ構築(Service)

- 設計
  - 作成したDeploymentへアクセスできるように、Serviceを作成
- 前提
  - DB/APサーバが起動して、初期化まで済んでいること
- シナリオ
  - 1. ConfigMap, Deployment, Serviceを作成
  ```bash
  kubectl apply -f weblog-web-fullset.yml 
  kubectl get pod,svc
  ```
  - 2. デバッグPodを作成して入る
  ```bash
  kubectl exec -it debug sh 
  ```
  - 3. WebサーバPodへ接続確認
  ```bash
  curl http://web-svc/
  exit
  kubectl delete -f weblog-web-fullset.yml 
  ```



# WEBサーバ構築(Service)

- システム構成図
  - L7ロードバランサーとして、Ingressを作成
- 前提
  - DB/AP/Webサーバが起動して、初期化まで済んでいること
- シナリオ
  - 1. Ingressを作成
  ```bash
  kubectl apply -f weblog-ingress.yml 
  kubectl get ing
  ```
  - 2. WebサーバPodへ接続確認
  ```bash
  minikube addons enable ingresss
  curl http://web-svc/
  exit
  kubectl delete -f weblog-ingress.yml 
  ```

# まとめ

- 触れてない分野
- 設計
  - マイクロサービスアーキテクチャ
- 開発
  - AWS/GCPといったクラウドへの展開
  - Docker/Kubernetesを用いたCI/CD
  - MongDB, Node.js, Nginxといったミドルウェアの具体的な使い方
- 運用
  - ログ集約'監視/分析