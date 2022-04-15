---
title: "IAM"
---

# IAM (AWS Identity and Acccess Management)とは？
- AWSサービスに対する操作権制御
- AWSを利用するためのID発行/削除といったID管理と発行されたIDに対する操作権制御を行う

## 何ができるのか？
- Aさん：管理：作成、起動、終了　→ EC2
- Bさん：開発：一覧
- Cさん：監査：アクセス不可
- ユーザ：グループ：ポリシー

- Aさん：管理：作成、一覧、削除　→ S3
- Bさん：開発：一覧、取得
- Cさん：監査：アクセス不可
- ユーザ：グループ：ポリシー

- Aサーバ：バッチ：作成、一覧、削除　→ S3
- Bサーバ：アプリ：一覧、取得
- Cサーバ：Web：アクセス不可
- ユーザ：ロール：ポリシー(ユーザやグループに付与するロールと同一)

# AWS管理ポリシーと、カスタマ管理ポリシー
- AWS管理ポリシー
  - AWSがあらかじめ作成して提供しているポリシー
- カスタマ管理ポリシー
  - 自前で任意のルールで作成するポリシー
- ポリシーの適用順番 (3層構造)
  - 3. 例外を拒否
  - 2. 必要な操作だけを許可
  - 1. AWSの基本はすべて拒否

# ポリシーを作成
1. 以下の作業ができるポリシーを作成
- S3のバケット一覧表示 ListBucket
- オブジェクトの一覧表示 HeadBucket, ListAllMyBuckets
- コンテンツの表示 GetObject
- 一覧表示 & 読み取り
2. IAM - アクセス管理 - ポリシーを開き、ポリシーの作成
- サービス：S3
  - アクセスレベル：
    - リスト：ListAllMyBuckets、ListBucket
    - 読み取り：GetObject
  - リソース:全て
  - ポリシー名：tastylog-dev-s3-readonly-iam-policy

# ユーザとグループを作成
1. data_analyst (データ分析)グループの作成(作成したポリシーをアタッチ)
- ユーザグループを作成
  - グループに名前を付ける:data_analyst
  - 許可ポリシーを添付 :s作成したポリシー
1. tanaka tsuyoshi ユーザを作成
- ユーザを作成
  - ユーザー：tanaka_tsuyoshi
  - AWS マネジメントコンソールへのユーザーアクセスを提供する
    - IAM ユーザーを作成します
    - 自動生成されたパスワード
- 許可を設定
  - ユーザーをグループに追加
- ログインしてみる
  - EC2 が見れない
  - S3一覧のみ見れる

# ロールの作成
1. data_analyst (データ分析)ロールの作成(作成したポリシーをアタッチ)
- ロールを開く、作成
- ユースケース:EC2
- ポリシー：作成したS3のやつ
- 名前：tastylog-dev-dataanalyst-iam-role
2. 任意のEC2 にロールを設定して、パケットん読み取りができることを確認
- バケットを作成
- パブリックアクセスをすべて ブロック： アンチェック
- 名前：tastylog-sample-dev-pabucke
```json
 "Statement": [
        {
            "Sid": "Stmt1708080431156",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:*",
            "Resource": "arn:aws:s3:::tastylog-sample-dev-pabucket"
        }
    ]
```
- ec2インスタンスを起動
- aws configure
- aws s3 ls s3://tastylog-sample-dev-pabucket/ でS3にアップロードしたファイルが見れるか確認
-