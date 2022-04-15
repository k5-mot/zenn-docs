---
title: "minikube備忘録"
---

# minikubeの使い方

- クラスタ実行/停止/状態確認
```bash
minikube start --vm-driver=none
minikube stop
minikube status
```
- アドオン追加/削除/一覧確認
```bash
minikube addons enable <ADDON_NAME>
minikube addons disable <ADDON_NAME>
minikube addons list
```

# VSCodeのRemoteSSH拡張機能を使って、仮想マシン内のファイルを編集する

1. VSCodeの[Remote Development](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack)拡張機能をインストール
2. 左部サイドバーの「Remote Explorer」をクリック
3. 左部サイドバー内の上部のプルダウンから、「Remotes (Tunnels/SSH)」を選択
4. 「SSH」項目の「Open SSH Config File」をクリック
5. 以下のSSHコンフィグを記述し、保存
```ssh_config
Host minikube
    HostName 192.168.195.129
    User root
```
6. 左部サイドバーの「Remote Explorer」をクリック
7. 「minikube」をクリックし、「Connect in New Window」をクリック
8. 「Select the platform of the remote host "minikube"」で「Linux」を選択
9. 「Open Folder」で「/ (ルートディレクトリ)」を選択