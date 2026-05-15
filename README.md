# my-site

Ruby on Rails で構築した個人ポートフォリオサイト。ブログ機能付き。

## 技術スタック

- Ruby 4.0 / Rails 8.1
- SQLite
- Tailwind CSS v4
- Hotwire（Turbo / Stimulus）
- Action Text（Trix エディタ）
- Active Storage + AWS S3
- RSpec / Capybara
- Kamal（デプロイ）
- Docker / GitHub Container Registry
- AWS EC2 / S3 / Route53

## 開発環境のセットアップ

devcontainer を使用。VS Code で `.devcontainer` を開くと自動でセットアップされる。

```bash
# DB セットアップ
bin/rails db:migrate
bin/rails db:seed   # 管理ユーザー作成

# 開発サーバー起動
bin/dev
```

## テスト

```bash
bundle exec rspec
```

## 管理画面

`http://localhost:3000/admin` からアクセス。ログインには `db:seed` で作成した管理ユーザーを使用。

## デプロイ

[Kamal](https://kamal-deploy.org/) を使用して AWS EC2 にデプロイ。

```bash
bin/kamal setup   # 初回のみ
bin/kamal deploy  # デプロイ
```
