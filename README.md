# my-site

Ruby on Rails で構築した個人ポートフォリオサイト。ブログ機能付き。

## 技術スタック

- Ruby 4.0 / Rails 8.1
- SQLite
- Tailwind CSS v4
- Hotwire（Turbo / Stimulus）
- Action Text（Trix エディタ）
- RSpec / Capybara

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

[Kamal](https://kamal-deploy.org/) を使用。
