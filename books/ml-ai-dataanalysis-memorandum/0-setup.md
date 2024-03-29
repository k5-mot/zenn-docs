---
title: "AIとは？"
---


# AI開発の基礎

- 独自アルゴリズムを作成
  - 研究者による独自アルゴリズムを開発
  - 公開されたAIモデルを理解し、構築できる
    - 研究、R&D段階
- 完成アルゴリズムを活用
  - すでに開発されたアルゴリズムを借りてモデル構築
  - ライブラリとして既存アルゴリズムを提供
    - Tensorflow
    - scikit-learn
    - Caffe / Caffe2
    - Chainer
    - Torch
    - Theano
    - Nxnet
    - CNTK
    - Keras
- AIプラットフォームを活用
  - ライブラリを活用した開発を支援する環境を提供
- 学習済みAIモデルを活用
  - 学習済みのAIモデルをAPIサービスとして提供

- ライブラリ型開発
  - ライブラリを活用することで、簡易なコーディングでAIモデルが開発できる
  - 最も活用されるライブラリは、Googleが提供するTensorFlow
- AIプラットフォームを活用
  - プラットフォームはAIモデル開発の開発支援環境を提供する
    - ↓ AIインフラ
    - ↓ TensorFlowなどのライブラリを使って複雑なAIアルゴリズムを実装する
    - ↓ GUIツール、管理機能など
- APIサービス
  - APIサービスは学習済みAIをAPIを経由してアプリケーションに組み込むことができるサービス
  - AI活用アプリ (独自コーディング部分)
  - (API呼び出し) ↓ ↑ (AI結果提供)
  - クラウド (画像識別API)
  -  ↓ ↑ 
  -  顔画像
- AIシステムの構成
  - AIシステムは、AIを動かす専用チップを有したサーバにより、AIソフトウェアを動かすのが基本構成
  - 技術スタック
    - AIアプリケーション
      - AIアプリケーションとして　ソフトウェアのように活用する
    - ↑
    - AIアルゴリズム (ソフトウェア)
      - オリジナルのAIアルゴリズム  
        - オリジナルのAIアルゴリズムを作成して利用
      - 借りるAIアルゴリズム
        - 他社が開発したAIアルゴリズムをクラウドサービスなどから利用
    - ↑
    - サーバ(ハードウェア)
      - AI学習向けサーバ
        - AI専用チップを内蔵(GPU/TPU)。学習時には膨大に利用
      - AI運用向けサーバ
        - AI専用チップを内蔵(GPU/TPU)。運用時は数個利用
- AI関連企業
  - データ分析/AI開発ベンダー
    - Brainpad
  - AI開発支援サービス提供
    - AWS
  - AI研修サービス
    - Udemy
  - AI搭載アプリ/サービス提供
    - ChatGPT
  - AI向けインフラ提供
    - NVIDIA


# AIスキル体系

- AIスキル体系はデータサイエンス力に加えて、ビジネス力とデータエンジニア力の3要素で成り立っている。
- ビジネス力
  - 課題背景を理解した上で、AIでビジネス課題を解決する力
  - ビジネス力は技術者と現場のビジネスとをつなげる橋渡し人材としての力が求められる。
    - AIビジネス経営力 (戦略・事業立案)
    - AIビジネス企画力 (企画立案)
    - AIビジネス推進力 (プロジェクト管理)
- データエンジニア力
  - データサイエンスの利用環境を実装・運用する力
  - データエンジニア力はデータ基盤やデータ整備を行うための技術力が中心
    - データ処理 (データ収集・蓄積・加工・共有)
    - AI用環境構築 (AI用自社インフラ環境構築、AI用クラウド環境構築)
- データサイエンス力
  - 情報処理・人工知能・統計学などを理解し活用する力
  - データサイエンス力を向上するためには、数学(統計学)、プログラミングの知識が必要
    - ↓ プログラミング(R、Python、ライブラリ/パッケージの理解)
    - モデル構築力 (データハンドリング、AIモデル実装力、AI機能の理解)
    - ↑ 統計学
    - ↑ 数学(微分・積分、線形代数、確率統計)


# AI開発プロジェクトの全体像

- AI開発の大きな特徴
  - 大きな違いは「実証検証」と「システム開発」という２つのフェーズで構成されている
    - Phase 1. 「AI実証検証」データ分析フェーズ
      - PoC、データ分析
    - Phase 2. 「AIアプリ開発・運用」従来のようなシステム開発フェーズ
- AI開発プロジェクト体制
  - 開発体制もデータ分析チームとアプリ開発チームという２チーム体制になることが多い
  - データサイエンティストの一部やPMは、ビジネスサイドとのデータサイエンティストとの橋渡しができる必要がある。
  - データエンジニアリングチームが、データ整備支援やデータ処理の非機能要件を担当する
    - ビジネス側
    - ↕
    - プロジェクト責任者 (ビジネスとの橋渡し人材)
    - |
    - データ分析チーム(データサイエンティスト)、アプリ開発チーム(プログラマ) ⇔ データエンジニアリングチーム(基盤担当)
- 機械学習/ディープラーニングモデルの成否は実施してみなければわからないため、実証実験が必要
  - 機械学習/ディープラーニングモデルの特徴
    - データを学習させてみて初めて結果がどうなるかわかる
    - 良いアルゴリズムもデータ次第で成否が決まる
    - データの整備方法は業界業種で様々であり、収集整備が一番重要
  - ↓
  - 実証実験の必要性
    - 今使えるデータから何ができるのか見定める
    - 目的のAI成果を達成するためのアルゴリズムを見定める
    - トライ&エラーでAI開発を明確化する
- AIモデル開発プロセス
  - 開発プロセスをAI開発ベンダー目線で対応作業を細分化すると、以下のようになる
1. 【ビジネス】AI企画立案
2. 【ビジネス】実施の決定/予算取り
3. AI実証検証(PoC/データ分析)
   1. 【ビジネス】ベンダー選定
   2. 【技術】データ収集・整備
   3. 【技術】データ分析方針検討
   4. 【技術】データ前処理
   5. 【技術】AIモデル構築 
   6. 【ビジネス力】AIモデル評価 (検証結果に応じて、1. or 3-4.に戻る)
4.  AIアプリ開発・運用
    1. 【ビジネス力】実施の決定/予算取り
    2. 【技術】AIアプリ開発
    3. 【ビジネス力】仮運用・検証 (検証結果に応じて、1. or 3-4.に戻る)
    4. 【技術】AIアプリ導入
    5. 【技術】AIアプリ運用
    6. 【技術】AI運用データ蓄積
    7. 【技術】AIモデル再学習

# AI開発におけるビジネス力

- 「AI/ディープラーニングで何かやってよ！」という無茶ぶり...
- テクノロジーの高度化により、発注側とベンダーとの乖離が増大している！
- ビジネスとテクノロジーの融合
  - テクノロジーの進展により、ビジネスがITを利用する関係からビジネスとITの融合関係へ
    - 今までのテクノロジー活用
      - ビジネス → IT
      - ビジネスがITを利用する関係
      - 例：ERPが会計・生産管理を支えるなど
    - これからのテクノロジー活用
      - ビジネスとテクノロジーが融合
      - 例：IoTやAIによるビジネスモデルなど
  - テクノロジーを前提にビジネスを創造することが必須になる
    - IoT/人工知能/ブロックチェーン x 自社ビジネス(ビジョン/ミッション/コアビジネス) = 新ビジネスの創造
  - 特に、AIによる収益性への影響は全産業に及んでおり、全企業・全職種での活用が必須
  - とはいえ、AIなどでビジネスを検討できる人材が企業内に不足しており、企業側/ベンダー側双方の課題となっている。
  - 企業側のノウハウ欠如により、ソフトウェア開発の延長で、AIやIoT事業をコンサルやベンダーに丸投げする傾向が増加
    - 「AI/ディープラーニングを使った新規事業がしたい」
    - 自社がデジタルで何をすべきか検討できていない
  - 結果として、企業のテクノロジー導入が目的化してしまい、失敗プロジェクトが増加している
    - 典型的な失敗パターン
      -  目的なしにAI導入の検討を開始した
      -  必要なデータがない、もしくはデータの質が低い
      -  AIで目的を実現できるが、投資対効果に見合わない
      -  従業員の協力を得ることができない
  - AI 開発では、ビジネス力とアナリティクス/エンジニアリング力の両方が求められる
    - 【ビジネス】ビジネス課題整理
    - 【ビジネス】AIサービスモデル立案
    - 【ビジネス】ビジネス評価、関係部署での意思決定
      - 断裂：ビジネス上の課題や目的が曖昧で、分析やAI開発の方向性が定まらない
    - 【アナリティクス/エンジニアリング】AI実証検証(PoC/データ分析)
    - 【ビジネス】実証検証の評価
    - 【ビジネス】関係部署での意思決定
      - 断裂：検証結果に基づき、意思決定ができず、具体的な施策に進めない
    - 【アナリティクス/エンジニアリング】AI開発、試作実施
    - 【アナリティクス/エンジニアリング】AI運用、効果測定
  - AIスキルは、「課題を見つける力」「AIモデル構築力」「AI実行力」の３つが必要
    - 「ビジネス課題を見つける力」
      - 課題発見力、ビジネスドライブ力、顧客知識、コミュニケーション力、インタビュー力、業務知識、テクノロジー知識
    - 「AIモデルを構築する力」
      - 数学知識、統計学、エンジニアリング、プログラミング力、モデル構築力、コミュニケーション力
    - 「AIモデル実行する力」
      - 社内ネットワーク、ビジネスドライブ力、コミュニケーション力、テクノロジー知識
  - AIxビジネス力を獲得することで、初めて適切なAIサービス構築が可能となる
    - 目的なしにAI導入の検討を開始した
      - ⇒ 自社でAIの目的を明確にした上で、AI導入を進められる
    - 必要なデータがない、もしくはデータの質が低い
      - ⇒ AIに必要なデータについて、理解・精査できるようになる
    - AIで目的を実現できるが、投資対効果に見合わない
      - ⇒ 顧客ニーズなどを踏まえ、収益性を検討したうえで、AIを導入できる
    - 従業員の協力を得ることができない
      - ⇒ 従業員に研修することで、理解を広められる

# AI人材のタイプ

- データサイエンティスト
  - AIプログラマとデータサイエンティストとの間にある深い壁
  - AIプログラマ、非専門データサイエンティスト領域
    - 既存のアルゴリズムを活用
    - AIプラットフォームを活用
    - 学習済みAIモデルを活用
  - 専門データサイエンティスト、研究/R&D段階
    - 独自アルゴリズムを作成
    - 既存のアルゴリズムを活用
- 本物のデータサイエンティストとAIプログラマとのAIプロジェクトでの決定的な違い
  - API/ライブラリを利用したAI開発 ⇒ AIプログラマ、本物のデータサイエンティスト
  - オリジナルAIモデルの開発 ⇒ 本物のデータサイエンティスト
- 本物のデータサイエンティストとは、統計学、数学、データサイエンスそのものの専門家


# AIの民主化トレンド

- ノーコーディングによる、AIモデル開発支援ツールの普及による、AIの民主化が進展している
  - オリジナルAIモデル開発 ⇒ 大なり小なりの技術力が必要
  - ライブラリによるAIモデル開発 ⇒ 大なり小なりの技術力が必要
  - ノーコーディングAIモデル開発 ⇒ 誰でもAIモデルが作れる ⇒ AIの民主化
- AIモデルの簡易生成GUIツール
  - MS Azure Machine Learningは、コーディングなしにAIモデル構築が可能なツール
    - ただし、コーディングも併用可能
  - DataRobotは、正解トップクラスのAIモデルを容易に構築するクラウド型ツールを提供
  - MITの自動機械学習システム「Auto Tune Models (ATM)」は、作成した数千パターンのモデルを並行テストして評価し、最適なAIモデルを短期間に作成
- 今後、必要なAI人材
  - AIの民主化が進展すると、AIプログラマタイプの需要が減少する可能性がある
  - よって、ノーコーディングAI開発/ライブラリ開発とを、双方リードできる AI人材を目指すことが望ましい。


# AIスキルロードマップ

- AIスキル獲得をロードマップに基づいて、検討・整理する
- ビジネス力
  - AIビジネス力の基礎 ⇒ AIサービス構築力 ⇒ AIプロジェクト推進力 ⇒ AIによるデジタル戦略立案ノウハウ
  - AIビジネス力の基礎 ⇒ PowerBIなどデータ分析ツールの活用力 ⇒ 機械学習、GUIツールの活用力
- データサイエンス
  - 数学 ⇒ 統計学 ⇒ データサイエンス知識 ⇒ データ収集/前処理 ⇒ データ分析/機械学習活用力 ⇒ 深層学習活用力 ⇒ AI開発プロジェクト実践力
  - 数学 ⇒ コーディング                  ⇒ データ収集/前処理 ⇒ ライブラリ活用力         ⇒ API活用力      ⇒ AI開発プロジェクト実践力
- エンジニアリング
  - オンプレ基盤構築力 ⇒ データ処理基盤整備 ⇒ データ収集/前処理
  - クラウド基盤構築力 ⇒ データ処理基盤整備 ⇒ データ収集/前処理

# 企業として取り組むべきAI人材育成

- AI研究から進める企業と、単にAI活用を進める企業では、求めるAIスキルのレベル感が異なる
  - AI活用企業
    - 画像識別など一般化したAI技術を活用して、ビジネスを生み出す企業
    - システム開発機能の１つとして、AI機能をビジネスに活用する
  - AI研究開発企業
    - 最先端のAI技術にR&Dから取り組み、業界をリードしたい企業
    - 本物のデータサイエンティストチームによる研究開発体制
- 全企業に求められるAI活用
  - 企業としては、データ経営ができる体制から始めて、AIによるビジネスモデル再構築をリードできる人材を整備する必要がある。
  - データ分析の経営活用標準化
    - 経営の意思決定をデータに基づいて実行
    - 各事業部も機械学習によるデータ分析が標準化
  - AIのビジネス活用推進
    - 既存ビジネス/業務へのAI活用
    - AIによるビジネスモデル再構築/新サービス立案
- 多くの企業において、組織的にAI活用するためのノウハウや知識が欠如していることが課題
- 中長期的にデジタル活用が可能となる組織として、自立自走するためのDXを実現する。
  - 経営者/事業部長
    - AI知識が欠如しているため、活用に向けた適切な経営判断ができない
    - AI知識を有している経営者がAI活用に向けたビジョンやビジネスモデルを念頭に事業を運営する
  - 経営企画・事業部スタッフ
    - AIノウハウがないため、AI活用計画が立案できない
    - また、AIを理解しているスタッフがいてもAI促進に向けたコミュニケーションがとれない
    - AUノウハウを有したビジネス人材が、AI企画やビジネスモデルを立案して、社内で推進することができる。
  - 情報システム部
    - ノウハウがないため、AI開発がベンダー依存となる。
    - または、一部モデル構築ができるも、社内展開できない
    - 経営企画とAI実装について、コミュニケーションをとり、実装支援に向けたインフラ整備・ベンダー調整ができる
  - アナリティクス部
    - 基本的に存在しない
    - データ分析や機械学習モデル構築を主体的に実施して、経営判断や実証実験に貢献できる
- 今後の経営には、社長/経営企画直下にデータサイエンティストを配置するなど、経営とデータサイエンスをつなげる組織構成・データ経営文化の構築が不可欠
  - 経営陣
    - 経営企画(マーケティング含む)
    - データサイエンス組織(IT含む)
    - デザイン組織(ビジネスデザイン含む)
- AI促進する組織文化
  - IoT/AIビジネス作りに必要となる各部門から選抜メンバーを集めて、IoT/AIビジネスを検討する
  - IoT/AI推進チーム的な

# AI競争の中の日本

- デジタルビジネスの必要性
  - 自動車販売からスマートシティと連携した、モビリティサービス
  - 自動車販売業 ⇒ モビリティサービス
- トヨタの事例
  - 2018年に、トヨタはモビリティサービスプラットフォーム(e-pallete)を発表
- ゲームルールの変化
  - ゲームのルールが変わるため、自社ビジネスそのものを考え直す必要がある。
  - 新ビジネス/技術登場 ⇒ 業界構造/ルールの変化 ⇒ 同じやり方で勝てない
    - Uberシェアリングサービスの出現
      - 配車データ分析による最適な配車サービスの実現
      - 低価格で高品質なサービス
    - 自動車業界モデルが大打撃を受ける
      - 既存のタクシー業界/レンタカー業界の低迷
      - シェアリングの台頭による、自動車販売の減速
    - 既存企業もシェアリングへの戦略転換
      - トヨタのUberへの出資
      - シェアリング事業への進出
      - スマートシティ型のモビリティサービス業へと大転換
- データ保有力
  - 米6社+中3社が、ビッグ9と呼ばれる
  - データ活用の軍拡競争が起こっている
    - Microsoft、Apple、IBM、Google、Amazon、Facebook
    - Tencent、Alibaba、Baidu
- 日系企業は勝負できない
  - データ人材の活用力xデータ技術力xデータ保有力で劣るため、勝負にならない
    - 日本語データという優位性を活用するか
    - サービス開発という独自性を追求するか
- 日系企業の弱点
  - 致命的な対応スピードの遅さ
  - 米は、アジャイルとトップダウン経営
  - 中は、トップダウンとプライバシー保護の緩さ
　- 日は、デジタルで何をすべきか検討できていない、自社ポジションを喪失するかも
　- 自動車も自動運転で破壊されるかも
- ガラパゴスの限界
  - 確実に縮小する国内市場でにっちに追いつめられる
  - 少子高齢化による人口減と購買行動の変容 ⇒ 日本市場の恒常的な縮小傾向
  - グローバル企業による軍拡競争 ⇒ ガラパゴスな日本的ビジネス追及
    - ジリ貧

# AI戦略立案

- 企業のAI戦略
  - ビジネスモデル再構築
  - AI活用組織に向けた組織改革
- BCGのデジタルチーム
  - 戦略コンサルティングファームもAI開発できる体制を整備して、課題解決xAI開発で対応している
  - BCGデジタル戦略チーム
  - BCGデジタルデータサイエンティストチーム
- デジタル戦略立案・実行ステップ
  - 自社ビジネス再定義
    - デジタルトレンド調査
    - 将来シナリオ分析
    - リポジショニング
  - ビジネスモデル立案
    - デジタルビジネスユースケース調査
    - デジタルビジネス案の詳細化
  - ビジネスモデル実行
    - 現状とのGAP分析
    - デジタル組織改革の実施
    - 実行支援

# AIスキルの獲得方法

- データサイエンススキルのベースは数学・統計学だが、ここから始めると挫折につながる
- まずは、R/Pythonを利用したデータ分析力の獲得を目指し、機械学習の初歩を理解することから始める

- データ分析力向上
  - データ解析用パッケージ
    - pandas,numpy,matplotlib
  - 機械学習用ライブラリ
    - scikit-learn
- 数学、統計学
  - 簡単な機械学習モデルが組めるようになると、数学を学習する必要性が出てくる
  - AI論文が理解できるようになる
  - パラメータ設定を理解できる
  - 機械学習モデルを理解できる
- AIビジネス力
- データサイエンス知識
- データ収集/前処理
  - スクレイピング
- 深層学習
- ライブラリ活用
- データ分析
  - PowerBI
  - Tableau
- 機械学習GUIツール
  - Azure Machine Learning
  - IBM watson
  - Google Home Dialog Flow
- API活用
- AI開発プロジェクト実践力
  - AI開発技術を学びたて人材は、「実践不足 ⇔ 実プロジェクト不足」の負の連鎖により、自立自走できない。
  - データ分析方針立案
    - データからAIモデルが構築できるか机上検証する
    - データ分析に利用するデータ項目の組み合わせの仮説を設定する
    - 利用するAIアルゴリズムを想定する
  - AIモデル構築
    - 最適なアルゴリズムの選択
    - アルゴリズムの最適なパラメータの設定
    - AI精度が悪いなどうまくいかなかったケースへの対処
    - オリジナルAIモデルによる対応
  - Kaggle
- データエンジニアリング
  - AWS SAA