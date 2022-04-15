---
title: "RDS"
---

# Amazon Relational Database Service(RDS)とは？
マネージドなリレーショナルデータベースサービス。
- AWSにおけるマネージドの意味は、(ハードウェア、ネットワーク機器などの)運用をAWSがやってくれるサービス。
- RDSでは、Aurola、MySQL、MariaDB、PostgreSQL、Oracle、MS SQLが利用できる。
- Aurolaは、Awsが構築したRDBで、MySQLかPostgreSQL互換かを選択できる。

# RDS構築手順
1. RDS用セキュリティグループを作成

| Purpose          | SG Name        | SG Inbound Rule      | SG Outbound Rule                  |
| ---------------- | -------------- | -------------------- | --------------------------------- |
| DB server (RDS)  | service-db-sg  | MySQL(3306)          |                                   |

2. サブネットグループを作成
- サブネットグループの詳細

| 項目 | 内容                |
| ---- | ------------------- |
| 名前 | service-subnetgroup |
| 説明 |                     |
| VPC  | <作成したVPCを選択> |

- サブネットを追加

| 項目 | 内容                |
| ---- | ------------------- |
| アベイラビリティーゾーン |ap-northeast-1a, ap-northeast-1c |
| サブネット |     <作成したPrivate Subnetを選択>                |

3. パラメータグループを作成
- パラメータグループの詳細

| 項目                         | 内容     |
| ---------------------------- | -------- |
| パラメータグループファミリー | mysql8.0 |
| タイプ                       |          |
| グループ名                   |          |
| 説明                         |          |

4. データベースを作成 (マルチAZの場合)
- データベース作成方法を選択：標準作成
- エンジンのオプション

| 項目               | 内容            |
| ------------------ | --------------- |
| エンジンのタイプ   | MySQL           |
| エディション       |                 |
| エンジンバージョン | 8.0.35 (latest) |

- テンプレート: 開発/テスト
- 可用性と耐久性: マルチAZ DBインスタンス
- 設定

| 項目                  | 内容                     |
| --------------------- | ------------------------ |
| DB インスタンス識別子 | service-mysql-multiaz-db |
| マスターユーザー名    | admin                    |
| マスターパスワード    | <任意のパスワード>       |

- インスタンスの設定

| 項目                  | 内容                             |
| --------------------- | -------------------------------- |
| DB インスタンスクラス | バースト可能クラス - db.t3.micro |

- ストレージ

| 項目               | 内容 |
| ------------------ | ---- |
| ストレージタイプ   |      |
| ストレージ割り当て |      |

- 接続

| 項目                                        | 内容                                       |
| ------------------------------------------- | ------------------------------------------ |
| コンピューティングリソース                  | EC2 コンピューティングリソースに接続しない |
| Virtual Private Cloud (VPC)                 | <作成したVPC>                              |
| DB サブネットグループ                       | <作成したサブネットグループ>               |
| パブリックアクセス                          | なし                                       |
| VPC セキュリティグループ (ファイアウォール) | 既存の選択                                 |
| 既存の VPC セキュリティグループ             | <作成したセキュリティグループ>             |

- 追加設定

| 項目                  | 内容                           |
| --------------------- | ------------------------------ |
| 最初のデータベース名  | <任意のデータベース名>         |
| DB パラメータグループ | <作成したパラメータグループ>   |
| オプショングループ    |                                |
| バックアップ          | 自動バックアップを有効にします |
| バックアップ保持期間  | 7日間                          |

5. データベースを作成 (シングルAZの場合)
- 可用性と耐久性: マルチAZ DBインスタンス
- 接続

| 項目                                        | 内容                                       |
| ------------------------------------------- | ------------------------------------------ |
| コンピューティングリソース                  | EC2 コンピューティングリソースに接続しない |
| Virtual Private Cloud (VPC)                 | <作成したVPC>                              |
| DB サブネットグループ                       | <作成したサブネットグループ>               |
| パブリックアクセス                          | なし                                       |
| VPC セキュリティグループ (ファイアウォール) | 既存の選択                                 |
| 既存の VPC セキュリティグループ             | <作成したセキュリティグループ>             |
| アベイラビリティーゾーン                    | <DBを配置するAZ>                           |

# EC2経由でのRDSへの接続
1. Publicな仮想マシンにSSH接続
```bash
ssh -i "<キーペア>" ec2-user@<EC2のPublic IP>
```
2. SQL Clientインストール
```bash
sudo yum update
sudo yum remove -y mariadb-*
sudo yum localinstall -y https://dev.mysql.com/get/mysql80-community-release-el7-11.noarch.rpm
sudo yum install -y --enablerepo=mysql80-community mysql-community-client
mysql -uadmin -p <RDSのエンドポイント>
```

# MySQL Clientのダウンロード
1. Oracleプロファイル作成
2. Installer for WindowsをDL (https://dev.mysql.com/downloads/)
3. インストーラを起動
4. Customインストール
  - 「MySQL Servers」 - 「MySQL Server」 - 「MySQL Server 8.0」 - 「MySQL Server 8.0.36 - X64」
5. SQL Serverの設定はしない(Type and NetworkingでCancel)。SQLクライアントのみ使うため。
6. SQL Clientを環境変数に追加(C:\Program Files\MySQL\MySQL Server 8.0\bin)

# SSH Port Forwardingを用いた、ローカルからRDSへの接続
・DBサーバへAPサーバ経由でポートフォワーディングする
1. SSHポートフォワーディング
```bash
ssh -i "<キーペア>" -NL 13306:<RDSのエンドポイント>:3306 ec2-user@<EC2のPublic IP>
# 別のシェルで下記のコマンドを実行する
mysql -uadmin -p -P13306
```
2. データベースを初期化
3. データベースを検証
```bash
mysql -uadmin -p -P13306
use <作成したデータベース名>;
show tables;
select * from <作成したテーブル名> limit 10;
```

# RDSのバックアップ
- オンプレミスの場合、データベースからダンプファイルを定期的に出力する
- AWS RDSの場合、RDSからスナップショット(マシンイメージ全体)を定期的に出力する
  - スナップショットは自動または手動で取得できる
    - 自動の場合、DB削除時に消える
    - 手動の場合、DB削除時に消えない

# スナップショットの取り方
1. アクション - スナップショットの取得をクリック
2. スナップショット名を入力。末尾に日付を入れるとよい。

# DBのリストア
EC2の停止・起動のようなものではなく、スナップショットを元に新規インスタンスを起動する
1. バックアップ元の識別子を変更、
- RDSでデータベースを選択し、「変更」をクリック、
- 「DBインスタンスの識別子」を「\*」から「\*-old」に変更する。(このとき、エンドポイントも変更される)
- 「すぐに変更」を選択する
:::message
普通にRDSを消すと、自動バックアップも削除されるのでこの工程を踏むこと
:::
2. 変更前の識別子で新規インスタンスを起動(リストア)
- 「アクション」 - 「スナップショットを復元」をクリック
- 可用性と耐久性：単一の DB インスタンス
- インスタンスの設定

| 項目                  | 内容                             |
| --------------------- | -------------------------------- |
| DB インスタンスクラス | バースト可能クラス - db.t3.micro |

- 接続

| 項目                                        | 内容                                       |
| ------------------------------------------- | ------------------------------------------ |
| コンピューティングリソース                  | EC2 コンピューティングリソースに接続しない |
| Virtual Private Cloud (VPC)                 | <作成したVPC>                              |
| DB サブネットグループ                       | <作成したサブネットグループ>               |
| パブリックアクセス                          | なし                                       |
| VPC セキュリティグループ (ファイアウォール) | 既存の選択                                 |
| 既存の VPC セキュリティグループ             | <作成したセキュリティグループ>             |
| アベイラビリティーゾーン                    | <DBを配置するAZ>                           |

- 追加設定

| 項目                  | 内容                           |
| --------------------- | ------------------------------ |
| 最初のデータベース名  | <任意のデータベース名>         |
| DB パラメータグループ | <作成したパラメータグループ>   |
| オプショングループ    |                                |
| バックアップ          | 自動バックアップを有効にします |
| バックアップ保持期間  | 7日間                          |

3. 消したくない自動バックアップをS3へ移動
- 「アクション」 - 「Amazon S3にエクスポート」
4. 元のデータベースを削除(このとき、自動バックアップも削除される)
- 「最終スナップショットを作成」をアンチェック
- 「自動バックアップを保持」をアンチェック

# DBの削除
```sql
show databases;
use "データベース名";
show tables;
select * from "テーブル名" limit 10;
delete from "テーブル名" where id<>1; # 1つ以外消す
```