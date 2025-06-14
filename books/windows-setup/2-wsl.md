---
title: "WSLのセットアップ手順"
---

# 概要
WSLをセットアップする手順をまとめる。

# 手順

## passwordless sudo を設定する.

```bash
sudo visudo
```

```diff
# User privilege specification
root    ALL=(ALL:ALL) ALL
+ username   ALL=(ALL:ALL) NOPASSWD: ALL

# Members of the admin group may gain root privileges
%admin ALL=(ALL) ALL
```

## Ubuntu の apt パッケージを更新する.

```bash
sudo apt-get update
sudo apt-get upgrade -y

# for Docker installation
sudo apt-get -y install --no-install-recommends apt-transport-https ca-certificates curl gnupg2
# for miscellaneous tools
sudo apt-get install -y build-essential net-tools wget lsb-release git jq unzip

sudo apt-get autoremove -y
sudo apt-get clean
```

## Docker をインストールする.

- 参考資料
    - [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)

```bash
# Uninstall old versions.
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done

# Set up Docker's apt repository.
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

# Install the Docker packages.
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Verify that the installation is successful.
sudo docker run hello-world

# Add your user to the docker group.
sudo usermod -aG docker $USER
```

## WSL2 で VSCode を使えるようにする.

- 参考資料
    - [WSL での Visual Studio Code の使用を開始する | Microsoft Learn](https://learn.microsoft.com/ja-jp/windows/wsl/tutorials/wsl-vscode)

```bash
# ⚠️ bash on WSL で実行する.
code .
```
