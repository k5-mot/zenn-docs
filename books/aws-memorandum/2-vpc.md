---
title: "VPC"
---

# IP Addressとは？
0-255の10進数表記４つを組み合わせて表現されるIPアドレス。

## Public IP Addressとは？
インターネットから見て、一意に特定できるIPアドレス。

## Private IP Addressとは？
内部ネットワークのみで使えるIPアドレス。他のネットワークと重複する可能性がある。

## ルーターとは？
Public IPとPrivate IPを変換し、ネットワーク同士をつなぐ機器。

## IPアドレスのサブネットマスクとは？
ネットワーク部とホスト部で切り分けるマスク。

:::message
例.

| Name | Content |
| ---- | ---- |
| IP Address  | 192.168.0.1    |
| Subnet Mask | 255.255.255.0  |
| CIDR        | 192.168.0.1/24 |
:::

# AWS Regionとは？
地理的に離れたデータセンター群。

:::message
例.

ap-northeast-1 (東京)、ap-northeast-3 (大阪)、us-east-1 (バージニア北部)、...
:::

# AZ (Availability Zone)とは？
AWS Regionを細かく分割した、単一または複数のデータセンター。

AZは、電気的に独立しているため、耐障害性のあるサービスを作成する際は複数のAZ(マルチAZ)を用いられる場合が多い。
(具体的に、あるAZで障害が起きた時に、別のAZにAWSリソースをフェールオーバー(移行)し、耐障害性を実現する。)

:::message
ap-northeast-1のAZの例.

ap-northeast-1a、ap-northeast-1c、ap-northeast-1d
:::

# VPC (Virtual Private Cloud)とは？
プロジェクト/サービス/ソリューションなどの単位でAWS内に作成される、プライベートな仮想的なネットワーク空間。
VPCは、複数のAZを跨いで配置できるが、Regionを跨いで配置できない。
VPC内では、外からアクセスできないクローズドなネットワーク空間(Private Subnet)を作成できる。

## VPCのアドレス範囲とブロックサイズ
VPCは以下のアドレス範囲から、/16-/28のブロックサイズで作成できる。
- 10.0.0.0 - 10.255.255.255
- 172.16.0.0 - 172.31.255.255
- 192.168.0.0 - 192.168.255.255

:::message
例.

| Name                             | Content      | Note                                      |
| -------------------------------- | ------------ | ----------------------------------------- |
| VPC                              | 10.0.0.0/16  | 10.0.{0-255}.{0-255}のIPアドレスを利用できる |
| Public Subnet  (ap-northeast-1a) | 10.0.10.0/24 | 10.0.10.{0-255}のIPアドレスを利用できる      |
| Private Subnet (ap-northeast-1a) | 10.0.11.0/24 | 10.0.11.{0-255}のIPアドレスが利用できる      |
| Public Subnet  (ap-northeast-1c) | 10.0.20.0/24 | 10.0.20.{0-255}のIPアドレスを利用できる      |
| Private Subnet (ap-northeast-1c) | 10.0.21.0/24 | 10.0.21.{0-255}のIPアドレスが利用できる      |

- Public Subnet (ap-northeast-1a)のルートテーブル

| Destination  | Target |
| ------------ | ------ |
| 0.0.0.0/0    | IGW    |
| 10.0.0.0/16  | local  |
:::

# Subnet
サブネットは、複数のAZを跨いで配置できない。
マルチAZ構成の場合、各AZにPublic/Private Subnetを1つずつ作成するのがベストプラクティス。

## Public Subnetとは？
インターネットと通信できるサブネット。ルートテーブルでデフォルトゲートウェイ(0.0.0.0/0)が
IGW(インターネットゲートウェイ)に流れるように設定されたサブネット。

Public Subnet内で作成されたEC2には、AWSがプールしているパブリックIPアドレスが割り当てられる。
このIPアドレスは、EC2が起動されるごとに変更される。

:::message alert
このパブリックIPアドレスを固定した場合、Elastic IPを使う必要がある。
AWSリソースに関連付けされていないElastic IPは、課金対象となるので気を付けること。
:::

## Private Subnetとは？
Public Subnetとは異なり、ルートテーブルにIGWを設定していないサブネット。

# ルートテーブルとは？
サブネットごとに作成するもので、異なるネットワーク(サブネット)間で通信するための経路情報を保存した、ルーター的なもの。
Public/Privateでルートテーブルを1つずつ作成するのがベストプラクティス。

# セキュリティグループ (SG: Security Group)とは？
通信のフィルタリングを行うファイアウォール。
インバウンド(入ってくる通信)とアウトバウンド(出ていく通信)ごとにルールを作成できる。
用途に合わせて、SGを作成するのがベストプラクティス。

:::message
例.

| Purpose          | SG Name        | SG Inbound Rule      | SG Outbound Rule                  |
| ---------------- | -------------- | -------------------- | --------------------------------- |
| Web server (ALB) | service-web-sg | HTTP(80), HTTPS(443) | Node(3000)                        |
| AP server (EC2)  | service-app-sg | Node(3000)           | HTTP(80), HTTPS(443), MySQL(3306) |
| DB server (RDS)  | service-db-sg  | MySQL(3306)          |                                   |
| Ops/Mng (EC2)    | service-op-sg  | Node(3000), SSH(22)  | HTTP(80), HTTPS(443)              |
:::

:::message alert
社内プロキシがある場合、送信先はプロキシサーバに絞ったほうがいいかも...
:::

# インターネットゲートウェイ (IGW: Internet Gateway)とは？
VPCはクローズドなネットワークであり外部通信できないため、インターネットへ接続する出入り口として、IGWを配置する必要がある。
