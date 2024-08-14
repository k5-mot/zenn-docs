---
title: "大喜利特化LLM「watashiha-gpt-6b」を触ってみる..."
emoji: "🙆"
type: "tech" # tech: 技術記事 / idea: アイデア
topics: []
published: false
---

# 概要

大喜利特化LLM「[watashiha-gpt-6b](https://huggingface.co/watashiha/watashiha-gpt-6b)」をOllamaで動かしてみる

```bash
./watashiha
├─Modelfile
└─watashiha-gpt-6b-q4_K_M.gguf
```

# 手順

## 1. Modelfileを作成

- `PARAMETER`は、[使用方法](https://huggingface.co/watashiha/watashiha-gpt-6b)のパラメータを流用する
- `PARAMETER`の`stop`は、終了シーケンス`<EOD>`を指定する
- `TEMPLATE`は、[使用方法](https://huggingface.co/watashiha/watashiha-gpt-6b)を参考にする

```Dockerfile:./watashiha/Modelfile
FROM ./watashiha-gpt-6b-q4_K_M.gguf

PARAMETER num_predict 32
PARAMETER top_p 0.9
PARAMETER top_k 50
PARAMETER stop "<EOD>"

TEMPLATE """お題:{{ .Prompt }}<SEP> 回答:{{ .Response }}<EOD>"""
```

## 2. HuggingFaceからGGUFファイルをダウンロード

- GGUF形式で提供している、[mmnga/watashiha-gpt-6b-gguf](https://huggingface.co/mmnga/watashiha-gpt-6b-gguf)を使わせていただく

```bash
wget -P . https://huggingface.co/mmnga/watashiha-gpt-6b-gguf/resolve/main/watashiha-gpt-6b-q4_K_M.gguf
```

## 3. ollamaで`watashiha`を起動する

```bash
ollama create watashiha:6b -f ./Modelfile
```

## 4. `watashiha`を試してみる

```bash
ollama run watashiha:6b
```

# まとめ

お題は[大喜利総合サイト](https://chinsukoustudy.com/og-top/og-summary/)から...

```bash
ollama run watashiha:6b

>>> こんなサウナは嫌だ、どんなサウナ？
お化け屋敷
```

😂
