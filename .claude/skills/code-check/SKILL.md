---
name: code-check
description: ユーザーが「品質チェック」「テストとlintを実行」「コードチェック」と言ったとき、またはコード品質をテストとlintで確認したいときに使用するスキル。RSpec と RuboCop を実行して結果をレポートする。
---

# Code Check

RuboCop（Lint）と RSpec（テスト）を順に実行し、コード品質をチェックしてサマリーをレポートする。

## 手順

### 1. RuboCop を実行

```bash
bundle exec rubocop
```

出力から以下を集計する：

- オフェンス総数
- 検査ファイル数
- 各オフェンスの cop 名・重大度・場所・メッセージ

### 2. RSpec を実行

```bash
bundle exec rspec
```

出力から以下を集計する：

- 総テスト数、成功数、失敗数、pending 数
- 失敗したテストのファイル・行番号・エラーメッセージ

### 3. 結果をレポート

以下の形式でサマリーを日本語で表示する：

```
## コード品質チェック結果

### RuboCop
- 検査ファイル数: X
- オフェンス: X 件（error: X、warning: X、convention: X、refactor: X）

### RSpec
- テスト数: X（成功: X、失敗: X、pending: X）
```

- オフェンスがある場合：cop 名・ファイル・行・メッセージを列挙する
- 失敗テストがある場合：ファイル・行・エラー内容を列挙する

## 注意点

- RuboCop → RSpec の順で実行する（RuboCop が高速なため先に実施）
- RuboCop でオフェンスが出た場合は RSpec を実行せず、まず RuboCop のエラーを解消するよう促す
