---
title: "Windowsのセットアップ手順"
---

# 概要
Windowsをセットアップする手順をまとめる。

# 手順

## WinGet で必要なツールをインストールする.

```powershell
# ⚠️ 管理者権限のPowerShellで実行する.
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

winget install --id Microsoft.WindowsTerminal  -e --source winget
winget install --id Microsoft.PowerShell       -e --source winget
winget install --id JanDeDobbeleer.OhMyPosh    -e --source winget
winget install --id Microsoft.VisualStudioCode -e --source winget
winget install --id Git.Git                    -e --source winget
winget install --id Amazon.AWSCLI              -e --source winget
winget install --id Microsoft.AzureCLI         -e --source winget
```

## Windows Terminal/PowerShell/OhMyPosh をセットアップする.

### Nerd Fonts をインストールする.

- 参考資料
    - [Fonts | Oh My Posh](https://ohmyposh.dev/docs/installation/fonts#installation)

```powershell
oh-my-posh font install meslo
```

### Windows Terminal にNerd Fontsを設定する.

- 参考資料
    - [Fonts | Oh My Posh](https://ohmyposh.dev/docs/installation/fonts#configuration)

1. Windows Terminal を開く
2. 設定を開く (Ctrl + Shift + ,)
3. 以下の内容を `settings.json` に追加する

```json
{
    "profiles": {
        "defaults": {
            "font":{
                "face": "MesloLGM Nerd Font"
            }
        }
    }
}
```

### Oh My Posh をセットアップする.

- 参考資料
    - [Change your prompt | Oh My Posh](https://ohmyposh.dev/docs/installation/customize#themes)

```powershell
oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH/spaceship.omp.json" | Invoke-Expression
```

## VSCode をセットアップする.

### VSCode の拡張機能をインストールする.

```powershell
code --install-extension ms-vscode-remote.remote-containers
```

## Gitの設定をする.

```powershell
git config --global user.name "<nickname; e.g. John Doe>"
git config --global user.email "<email; e.g. john.doe@example.com>"
git config --global core.editor "code --wait"
git config --global merge.tool "code"
git config --global diff.tool "code"
```

## AWS CLI をセットアップする.

```powershell
aws configure
```

## Azure CLI をセットアップする.

```powershell
az login
```

## WSL2をインストールする.

- 参考資料
    - [WSL コマンドのインストール](https://learn.microsoft.com/ja-jp/windows/wsl/install#install-wsl-command)

```powershell
# ⚠️ 管理者権限のPowerShellで実行する.
wsl --install
wsl --install
ダウンロードしています: Ubuntu
インストールしています: Ubuntu
ディストリビューションが正常にインストールされました。'wsl.exe -d Ubuntu' を使用して起動できます
Ubuntu を起動しています...
Provisioning the new WSL instance Ubuntu
This might take a while...
Create a default Unix user account: username
New password:
Retype new password:
passwd: password updated successfully
To run a command as administrator (user "root"), use "sudo <command>".
See "man sudo_root" for details.

username@hostname:/mnt/c/Users/username$
```
