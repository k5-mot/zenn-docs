---
title: "AWS Secret Managerのパラメータストア"
---

# パラメータストアとは？
- ASM (AWS System Manager)に含まれる機能。
- 設定情報を管理できるキー・バリュー型のストレージ。

:::message
機密情報を扱いたい場合、類似サービス「AWS Secrets Manager」もあるが、課金対象である。
呼び出し回数が多い場合には、Secret Managerを使うべき。
ユースケースに応じて、適切なものを選ぶべき。
:::

# パラメータストアでできること
- キー・バリュー形式で保存できる
  - キーは階層構造をとれる
  - バリューは、文字列、文字列リスト、セキュア  文字列から選択できる
- 各種AWSサービスから参照・利用できる
  - EC2やLambdaからアクセスできる
  - `aws ssm get-parameters-by-path --path /sample/prod/app/DB_HOST`

# 使い方
1. AWSマネジメントコンソールまたはawscliから、パラメータを登録
2. EC2は起動時にパラメータストアの値を環境変数に取り込む

# AWS CLIとは？
- ローカルから、AWS APIを呼び出すことができるCLIツール。
- AWS API呼び出すことができるツール一覧
  - AWSマネジメントコンソール
  - AWSが提供する各種SDK
  - AWS CLI

# AWS CLIのインストールと設定の手順
1. AWS CLIのインストール
2. IAMユーザのアクセスキーを作成
-  「IAM」 - 「ユーザ」 - 「セキュリティ認証情報」
- 「コマンドラインインターフェイス (CLI)」を選択し、作成
3. AWS CLIの初期設定
- `aws configure`をして、「Access ID」と「Access Key」を入力する
- 「region」は、「ap-northeast-1」
- 「format」は、「json」

# パラメータの登録/変更/確認/削除 (AWS マネジメントコンソール)
1. 「System Manager」 - 「パラメータストア」を開く。
2. 「パラメータを作成」
- DBのユーザ名
  - 名前：`/sample/dev/app/DB_USER`
  - 値：`admin`
  - タイプ：文字列
- DBのパスワード
  - 名前：`/sample/dev/app/DB_PASS`
  - 値：`Passw0rd`
  - タイプ：安全な文字列
  - KMSキーソース：現在のアカウント

#  パラメータの登録/変更/確認/削除 (AWS CLI)
- 登録、変更
  - `aws ssm put-parameter --name <name> --value <value> [--type,--overwrite]`
- 取得
  - `aws ssm get-parameter --names <key> [--with-decryption]`
- パス配下パラメータ取得
  - `aws ssm get-parameter-by-path --path <key> [--with-decryption]`
- 削除
  - `aws ssm delete-parameters --names <key> [--with-decryption]`

# AWS CLIで、DB用のパラメータをパラメータストアに登録してみる
```bash
aws ssm put-parameter  --name /sample/dev/app/DB_USER --value admin --type String
aws ssm put-parameter  --name /sample/dev/app/DB_PASS --value Passw0rd --type SecureString
aws ssm put-parameter  --name /sample/dev/app/DB_USER --value root --type String --overwrite
aws ssm get-parameters --names /sample/dev/app/DB_USER --with-decryption
aws ssm get-parameters --names /sample/dev/app/DB_PATH --with-decryption
aws ssm get-parameters-by-path --path /sample/dev/app
aws ssm delete-parameters --names /sample/dev/app/DB_USER /sample/dev/app/DB_PASS
```

# EC2で、パラメータストアの値を取得
- AmazonLinux2には、デフォルトでAWS CLIがインストールされているが、初期化されていないため、region指定をする必要がある。
- IAMの操作権限制御をEC2に与え、パラメータストアにアクセスできるようにする。
1. パラメータストアに値を登録。
2. IAMでパラメータストアへのアクセス権限を渡す。
- 「ロールを作成」
  - 信頼されたエンティティタイプ：AWS のサービス
  - サービスまたはユースケース：EC2
  - ユースケース：EC2
  - 「次へ」
- 許可ポリシー：AmazonSSMReadOnlyAccess
3. EC2インスタンス作成時に、作成したIAMロールを付与
- `aws ssm get-parameters-by-path --path /sample/dev/app --region ap-northeast-1 --with-decryption`

# パラメータストアをどう設計するか？
- キー：`/sample/dev/app/DB_USER`
  - /プロジェクト名/環境/サーバロール/環境変数定義
    - 環境：`dev`, `stg`, `prod`
    - ロール：`web`, `user`, `corp` ,`admin`, `batch`
- バリュー：`admin`

# パラメータストアを使って、APサーバを再構築
1. パラメータストアに必要な情報を設定
- `/sample/dev/app/MYSQL_HOST`
  - 説明：
  - 値：`<RDSのエンドポイント>`
- `/sample/dev/app/MYSQL_PORT`
  - 値: `<RDSのポート>`
- `/sample/dev/app/MYSQL_DATABASE`
- `/sample/dev/app/MYSQL_USERNAME`
- `/sample/dev/app/MYSQL_PASSWORD`
2. AWSリソースにタグ付け
- VPC
  - `Project`=`sample`
  - `Env`=`env`
- EC2
  - `Type`=`app`
3. IAMでEC2読み取り権限を付与
- 作成したロールに、AmazonEC2ReadOnlyAccessポリシーをアタッチ
<!-- 4. MW,APPインストーラを解凍
　・https://docs.aws.amazon.com/ja_jp/sdk-for-javascript/v2/developer-guide/setting-up-node-on-ec2-instance.html
　・curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
　・ -->
