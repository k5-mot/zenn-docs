---
title: "GitLabとGitLab Runnerをcompose.yamlで起動し、Runnerを登録して、実際に動かすまでの手順"
emoji: "📝"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["docker", "gitlab"]
published: true
---

# 🤔 概要

GitLabとGitLab-Runnerをdocker-composeで起動した後、GitLabの全リポジトリで使用できるShare RunnerとしてGitLab-Runnerを登録する手順を示す。
また、リポジトリを新規で作成し、`.gitlab-ci.yaml`を動かし、動作確認する。


# 📜 手順

## 1. GitLabとGitLab-RunnerをDockerで起動する。

- 参考資料
  - [Install GitLab by using Docker | GitLab](https://docs.gitlab.com/ee/install/docker/index.html)
  - [Run GitLab Runner in a container | GitLab](https://docs.gitlab.com/runner/install/docker.html)

## 2. GitLabにrootユーザでサインインする

1. 初期パスワードを以下のコマンドで、見れる
    ```bash
    sudo docker exec -it gitlab grep 'Password:' /etc/gitlab/initial_root_password
    ```
2. ユーザ名`root`と、初期パスワードを入力してサインインする

- 参考資料
  - [Install GitLab by using Docker | GitLab](https://docs.gitlab.com/ee/install/docker/index.html#install-gitlab-using-docker-engine)

## 3. rootユーザのパスワードを変更する

:::message alert
24時間後に初期パスワードファイル`/etc/gitlab/initial_root_password`が消失するので、パスワードを変更すべき
:::

1. "ユーザアイコン" - "Preferences"をクリックする
2. サイドバーの"Password"をクリックする
3. rootユーザのパスワードを変更する

- 参考資料
  - [Install GitLab by using Docker | GitLab](https://docs.gitlab.com/ee/install/docker/index.html#install-gitlab-using-docker-engine)

## 5. GitLab上で、Instance runnerを新規作成する

1. "Admin Area"を開く
2. サイドバーの"CI/CD" - "Runner"クリックする
3. "New instance runner"をクリックする
4. Instance Runnerの設定をし、"Create runner"
   1. Platform: `Linux`
   2. Tags:
      1. Tags: `linux, alpine`
      2. Run untagged jobs: `✅ (チェックする)`
         1. Tagを付けないCI/CDがすべて、このRunnerで実行される
         2. Tagで、Linux/macos/WindowsのRunnerを振り分けるのがよい
   3. Configuration
      1. Runner description: `alpine-latest`
5.  runner authentication token (例: `glrt-XXXXXXXXXXXXXXXXXXXX`)を手元に控える

- 参考資料
  - [Registering runners | GitLab](https://docs.gitlab.com/runner/register/?tab=Docker)
  - [Control jobs that a runner can run | GitLab](https://docs.gitlab.com/ee/ci/runners/configure_runners.html#for-an-instance-runner-2)


## 6. GitLab RunnerをGitLabに登録する

1. トークンを控えたものに置き換え、以下のコマンドを入力する
```bash
sudo docker exec -it gitlab-runner \
gitlab-runner register \
  --non-interactive \
  --url "http://192.168.11.2/gitlab" \
  --token "glrt-XXXXXXXXXXXXXXXXXXXX" \
  --executor "docker" \
  --docker-image alpine:latest \
  --description "docker-runner"
```
2. Runnerの並行実行ジョブ数を`1`から`8`に変更する
```bash
sudo docker exec -it gitlab-runner /bin/bash -c "sed -i 's/concurrent.*/concurrent = 8/' /etc/gitlab-runner/config.toml"
sudo docker exec -it gitlab-runner /bin/bash -c "cat /etc/gitlab-runner/config.toml"
```
3. GitLab Runnerを再起動する
```bash
sudo docker restart gitlab-runner
```

- 参考資料
  - [Register with a runner authentication token | GitLab](https://docs.gitlab.com/runner/register/?tab=Docker#register-with-a-runner-authentication-token)
  - [Non-interactive registration | GitLab](https://docs.gitlab.com/runner/commands/index.html#non-interactive-registration)


## 7. 適当なユーザ/グループ/リポジトリを作成する

## 8. `.gitlab-ci.yaml`を実行する

1. 適当なリポジトリを開く
2. サイドバーの、"Build" - "Pipeline Editor"をクリックする
3. テンプレートのまま、"Commit changes"する
4. サイドバーの、"Build" - "Pipelines"をクリックする
4. "Status"列の"Running"をクリックする
5. しばらくして、すべて"Success"になったら、動作確認終了


# 📌 まとめ

お疲れ様です。
