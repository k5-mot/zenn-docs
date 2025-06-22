---
title: "練習環境のセットアップ"
---

# VMware Workstation PlayerでCentOS7の仮想マシンを作成する

1. [VMware Workstation Player](https://www.vmware.com/products/workstation-player.html)と[CentOS7](https://www.centos.org/download/)をダウンロードする
2. [VMware Workstation Player](https://www.vmware.com/products/workstation-player.html)をインストールする
3. VMware Workstation Playerで、CentOS7ベースの仮想マシンを作る
   1. 「新規仮想マシンの作成」をクリック
   2. 「インストーラディスクイメージファイル(*.iso)」にダウンロードしたCentOS7のISOを選択し、「次へ」
   3. 「フルネーム」「ユーザ名」「パスワード」「(パスワードの)確認」を任意に入力し、「次へ」
      - フルネーム：FULLTO NAMEKO
      - ユーザ名：user
      - パスワード：user
   4. 「仮想マシン名」を任意に入力し、「次へ」
   5. 「ディスク最大サイズ」に「20.0 GB」を入力し、「仮想ディスクを複数ファイルに分割」を選択し、「次へ」
   6. 「ハードウェアをカスタマイズ」
      - メモリ
        - この仮想マシンのメモリ：4GB (4096MB)
      - プロセッサ
        - プロセッサコアの数：2
   7. 「完了」をクリックし、仮想マシンを作成
   8. インストールが終わるまで待機

# 仮想マシンのIPアドレスを確認する

1. 以下のコマンドを入力し、`ens33`のIPアドレスを控える
```bash
ip -f inet a

# 以下、出力
2: ens33: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet 192.168.195.128/24 brd 192.168.195.255 scope global noprefixroute dynamic ens33
       valid_lft 1731sec preferred_lft 1731sec
```
2. WindowsのPowerShellで、SSH接続する
```bash
ssh user@192.168.195.128
```


# 作成したユーザに`sudo`権限を与える

1. `root`ユーザにログイン
```bash
su -
```
2. 作成したユーザに`sudo`権限を与える
```bash
visudo

# 以下の行を追加
user ALL=(ALL) NOPASSWD: ALL
```

# アップデートとユーティリティのインストール

```bash
yum update --assumeyes --obsoletes 
yum groups install --assumeyes "Server with GUI"   
yum groups install --assumeyes "Development Tools" 
```

# Dockerのインストール

1. `yum.conf`を修正
```bash
sed -i -e "/timeout\=/d"           /etc/yum.conf
sed -i -e "13s/^/timeout=300\n/g"  /etc/yum.conf
sed -i -e "/ip_resolve\=/d"        /etc/yum.conf
sed -i -e "14s/^/ip_resolve=4\n/g" /etc/yum.conf
```
2. `~/.curlrc`を修正
```bash
cat <<-EOF > ~/.curlrc
ipv4
EOF
```
3. Dockerに必要なパッケージをインストール
```bash
# Install conntrack
yum install -y conntrack-tools-1.4.4
# Install "Docker"
yum install -y yum-utils-1.1.31  device-mapper-persistent-data-0.8.5 lvm2-2.02.185
```
4. Dockerをインストール
```bash
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce-19.03.8 docker-ce-cli-19.03.8 containerd.io-1.2.13
```
5. Dockerの設定を修正
```bash
mkdir -p /etc/docker
cat <<-EOF > /etc/docker/daemon.json
{
  "dns": ["8.8.8.8"]
}
EOF
```
6. Dockerを有効化・起動
```bash
systemctl enable docker
systemctl start docker
```

# kubectlとminikubeをインストール

1. kubectlをインストール
```bash
# Install "kubectl"
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.18.2/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv -f ./kubectl /usr/local/bin
```
2. minikubeをインストール
```bash
# Install "minikube"
curl -Lo minikube https://storage.googleapis.com/minikube/releases/v1.9.2/minikube-linux-amd64
chmod +x minikube
install minikube /usr/local/bin
rm -f minikube
```
3. ファイアウォールを停止
```bash
# stop firewall
systemctl disable firewalld
systemctl stop firewalld
```
4. minikubeにアドオンを追加
```bash
/usr/local/bin/minikube start --vm-driver=none 
/usr/local/bin/minikube addons enable ingress
```
:::message alert
`minikube start --vm-driver=none`は、起動毎に実行する必要がある
:::
5. Dockerを再起動
```bash
# Docker restart and update DNS settings
systemctl restart docker
```