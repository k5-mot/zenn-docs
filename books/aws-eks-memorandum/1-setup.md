---
title: "Setup"
---


# IAMユーザを作成
- ルートユーザ
  - 全てのAWSサービスを利用できる特権ユーザ
  - アカウントの設定変更、サポートプランの変更などはルートユーザのみ
  - 通常の作業にルートユーザは使用しない
- IAMユーザ
  - IAMポリシーで許可されたAWSサービスを使用できる
  - 利用者ごとに作成し、通常の作業はIAMユーザを使用する

- 手順
1. 「ユーザの作成」
2. ユーザー名を入力、マネジメントコンソールへのアクセスをチェック
3. IAMユーザを作成、残りは任意で
4. ポリシーを直接アタッチする
5. AdministratorAccessをあたっち
6. ユーザの作成

# 請求アラートの作成
- AWSの利用料金が設定値を超えたら通知できる
- CloudWatchの機能を設定する
  - IAMでも請求の設定をできるようにする
  - 請求アラートを受け取る設定にする
  - CloudWatchで請求アラートを設定する

- 手順
アラーム - 請求　- アラームの作成
静的 - より大きい - 5USD
新しいトピックの背悪性
アラーム名：Billing_Alert
メール　comfirm subscription
アラーム画面をリロード
アクションが有効になっています

# AWS CloudSHell環境構築

- 右上のターミナルアイコンを押下
- Actionでファイルアップロードできる

# アクセスキー取得

- セキュリティ認証情報
- アクセスキーの作成
  - cliを選択
- aws configure
  - region ap-northeast-1
  - output json

# Amazon EKSとは？

- Kubernetesとは？
  - コンテナ化されたアプリケーションの展開、スケーリング、および管理を自動化するためのプラットフォーム
  - コンテナオーケストレーションエンジン
  - KubernetesはOSS
  - Kubernetesを利用するには、Kubernetesに対応した環境を用意する必要がある
- Amzon　EKS とは
  - Kubernetesを実行するために使用できるAWSのマネージド型サービス
  - Kubernetesを利用する際に、必要となるコントロールブレーンはAWSが提供する
  - ノードに関しても簡単に用意することができる
- KubernetesとEKSの関係
  - 利用者はKubernetesを操作するのみ
  - EKSであることは意識しない
  - 言い換えれば、Kubernetesに対応している各種ツールは、そのまま EKSでも利用できる
- EKSの捜査手段
  - eksctk
  - マネジメントコンソール、CLI
  - Terraform

# eksctlのセットアップ

```bash
# Cloudshell
mkdir ~/bin
curl --silent --location "https://github.com/eksctl-io/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
sudo mv /tmp/eksctl /home/cloudshell-user/bin
```

```bash
# Cloudshellにファイルをアップロードするには、左上のアップロードから行う
eksctl create cluster -f cluster.yaml # 10分くらいかかる
kubectl get node
eksctl delete cluster -f cluster.yaml # 2分くらいかかる

```
