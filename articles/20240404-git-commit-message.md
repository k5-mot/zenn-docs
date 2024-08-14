---
title: "Gitメッセージの書き方"
emoji: "📝"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: ["emoji","git"]
published: true
---

# 方針

1. 作業内容の分類に対応した絵文字を付加する
2. 作業理由を書く
3. 作業内容を書く

- 例: 「:sparkles: CSVファイルを入力するために、CSVLoaderを追加。」

## 1. 作業内容の分類に対応した絵文字を付加する

|分類|GitHub Flavored Markdown|GitLab Flavored Markdown|
|:---:|:---:|:---:|
|機能追加|:sparkles:`:sparkles:`|:sparkles:`:sparkles:`|
|機能改善|:+1:`:+1:`|:thumbsup:`:thumbsup:`|
|バグ修正|:bug:`:bug:`|:bug:`:bug:`|
|ドキュメント修正|:books:`:books:`|:books:`:books:`|
|リファクタリング|:memo:`:memo:`|:memo:`:memo:`|
|テスト関連|:test_tube:`:test_tube:`|:test_tube:`:test_tube:`|
|ツール・ライブラリ関連|:gear:`:gear:`|:gear:`:gear:`|

## 2. 作業理由を書く

- ○○のために、

## 3. 作業内容を書く

- ××をした。

# 参考資料

- [GitHub - angular/angular.js/DEVELOPERS.md](https://github.com/angular/angular.js/blob/master/DEVELOPERS.md#-git-commit-guidelines)
- [GitHub - carloscuesta/gitmoji](https://github.com/carloscuesta/gitmoji)
