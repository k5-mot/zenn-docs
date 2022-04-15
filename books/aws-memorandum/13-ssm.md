---
title: "SSM"
---

# SSM (AWS Secret Session Manager)とは？
- 踏み台サーバの代わり
- サーバへ接続する経路
- ユーザ → [HTTP/HTTPS] →　EC2(web/ap) →　←(アクセス許可)　ec2(踏み台)　←　運用ルーム(特定IP のみアクセス可能)
- メンテナンス時のみ、裏から入る
- 踏み台サーバは毎回つなぐ作るのはめんどい

- SSMは、踏み台サーバ準備やSSH接続許可なしにサーバ接続する仕組み
- 使うために
  - クライアント側
    - awscli session manager pluginのインストール
    - awscliを利用するためのiamユーザのアクセスキーの作成
    - ユーザにssmを利用するポリシーを作成する
  - サーバ側
    - ネットワーク設定
    - amazon-ssm-agentのインストール
    - ssmを利用するポリシーを与える

# クライアント側の準備
1. awscli, session manager pluginのインストール
```bash
session-manager-plugin #  これでいんすとーるされたか確認
```
2. IAM ポリシーの付与


# サーバ側の準備
- VPCの準備
1. 　DNS 解決を有効化(VPC-アクション-編集-DNSホスト名を有効化)
2. DNS ホスト名を有効化
3. InternetGatewayを追加

- EC2の準備
1. amazon-ssm-agentをインストール
2. publci ipの付与
3. SSM捜査権限の付与IAMロール( tastylog-dev-app-iam-roleにAmazonSSMManagedInstanceCoreポリシーを追加）
4. httpsアウトバウンドの許可　(セキュリティグループ)　(APサーバ用SGのHTTPSアウトバウンドルール のAnywhereを追加する)

# 仮想マシンへ接続(SSM)
1. ローカルから
```bash
aws ssm start-session --target <instance-id>
```
2. マネジメントコンソールの接続、セッションマネージャーから接続する

# 仮想マシンへ接続(SSH on SSM)
```ssh-config
# SSH over Session Manager
Host i-* mi-*
    ProxyCommand C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe "aws ssm start-session --target %h --document-name AWS-StartSSHSession --parameters portNumber=%p"
```
以下のコマンドでEC2インスタンスに接続できる
```bash
ssh -i devlog.pem ec2-user@i-* (インスタンスID)
```


# 仮想マシンへ接続(SCP on SSM)
```bash
scp -i *.pem <source> ec2-user@<instance-id>:<target>
```
