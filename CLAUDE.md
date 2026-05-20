# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## 開発環境

devcontainer 内で開発する。サーバー起動は `bin/dev`（Rails サーバー + Tailwind watch を同時起動）。

## コマンド

```bash
# 開発サーバー起動
bin/dev

# テスト実行
bundle exec rspec                          # 全テスト
bundle exec rspec spec/models/            # モデル spec のみ
bundle exec rspec spec/path/to/file_spec.rb:42  # 行番号指定で単一テスト

# Lint
bundle exec rubocop                       # チェック
bundle exec rubocop -a                    # 自動修正

# DB
bin/rails db:migrate
bin/rails db:seed                         # 管理ユーザー作成（development のみ。admin@example.com / password1234）

# デプロイ（Kamal）
# main へのマージ時、CI（スキャン・Lint・テスト）通過後に自動で bin/kamal deploy が走る
# GitHub Secrets に SSH_PRIVATE_KEY と RAILS_MASTER_KEY の登録が必要
bin/kamal setup   # 初回のみ。EC2 に Docker・Traefik をセットアップ
bin/kamal deploy  # 手動デプロイ
bin/kamal lock release  # デプロイが中断してロックが残った場合に解除

# 本番環境の操作（kamal aliases で短縮可能）
bin/kamal console  # Rails コンソール（= app exec --interactive --reuse "bin/rails console"）
bin/kamal shell    # bash シェル
bin/kamal logs     # ログ確認（-f でフォロー）
bin/kamal dbc      # DB コンソール
```

## アーキテクチャ

### 認証・認可

- `app/controllers/concerns/authentication.rb` — Cookie ベースのセッション認証。`before_action :require_authentication` で保護。
- `app/controllers/admin/base_controller.rb` — admin namespace の親クラス。`require_admin`（`Current.user&.admin?`）で管理者チェック。
- `Current` (`app/models/current.rb`) — リクエストスコープのセッション・ユーザー情報を保持。

### ルーティング構造

- `/` — サイトトップ（PagesController#index）
- `/blog` — 公開ブログ一覧・詳細（BlogPostsController）
- `/inquiries` — お問い合わせフォーム（InquiriesController、new/create のみ）
- `/privacy-policy` — プライバシーポリシー（PagesController#privacy_policy）
- `/admin` — 管理画面（admin namespace、要認証）
  - `/admin/blog_posts` — 記事管理（CRUD + publish/unpublish/preview）
  - `/admin/categories` — カテゴリー管理
  - `/admin/inquiries` — お問い合わせ管理（index/show。詳細アクセスで既読化）
- `/letter_opener` — 開発環境のみ。送信メールを確認できる UI

### モデル

- `BlogPost` — `has_rich_text :content`（Action Text）。`status` は integer enum（draft: 0, published: 1）。公開時は `content` 必須バリデーション。slug は `SecureRandom.hex(4)` で自動生成。
- `Category` — `has_many :blog_posts, dependent: :nullify`。
- `User` — `has_secure_password`。`admin` boolean で管理者判定。`has_many :blog_posts, dependent: :restrict_with_exception`。
- `Session` — ログイン時に生成されるセッションレコード。`Current.session` 経由でアクセス。
- `Inquiry` — お問い合わせ。`name/email/company_name/body/read`。`read` は詳細ページアクセス時に `true` へ更新。

### Active Storage

- development / test: ローカルディスク（`storage/` ディレクトリ）
- production: AWS S3（`config/storage.yml` の `amazon` 設定）
- S3 への画像アップロードはブラウザから直接行うため、S3 バケットに CORS 設定が必要

### 秘匿情報の管理

- 秘匿情報（AWS キー・GitHub トークン等）は `credentials.yml.enc` に保存（`VISUAL="code --wait" bin/rails credentials:edit` で編集）
- `.kamal/secrets` は `bin/rails credentials:fetch` 経由で読み込む設計。raw 値を直接書かない
- `config/master.key` は `.gitignore` 済み。git に含めない
- `credentials[:http_basic_auth]`（`name` / `password`）— 本番環境のログイン画面に HTTP Basic Auth をかける。未設定だと Basic Auth が常に拒否されログインページにアクセス不可になるため必須

### メーラー

- `ApplicationMailer` — `from` は `credentials.dig(:smtp, :user_name)` から動的取得。
- `InquiryMailer#notification` — お問い合わせ送信時に管理者へ通知。`deliver_later` で非同期送信。
- `NotificationMailer#sqlite_backup_failure` — バックアップ失敗時の通知。
- 開発環境は `letter_opener_web` でメール送信をキャプチャ（`/letter_opener` で確認）。本番は SMTP（Gmail）。

### フロントエンド

- Tailwind CSS v4（`tailwindcss-rails`）— `app/assets/tailwind/application.css` でビルド
- Trix エディタ（Action Text）— `app/javascript/application.js` で import
- pagy v43 — ページネーション。`Pagy::Method` を `ApplicationController` に include

### CSS の注意点

- `app/assets/tailwind/application.css` に `@import "../stylesheets/actiontext.css"` と `@import "./pagy-tailwind.css"` を含む
- `pagy-tailwind.css` は `@apply` を使うため Tailwind のビルドが必須。gem から手動コピーして管理。更新時は `find $(bundle show pagy) -name "pagy-tailwind.css"` でパスを確認してコピーする
- `config/initializers/pagy.rb` に `require "pagy"` が必要（Docker 環境で自動 require されないため）

### バックグラウンドジョブ

- Solid Queue を使用（Puma 内で動作、`SOLID_QUEUE_IN_PUMA: true`）
- 定期実行は `config/recurring.yml` で管理（cron 式または自然言語スケジュール）
- **cron 式はアプリタイムゾーン（JST）で評価される**。`0 3 * * *` = 毎日 3:00 JST。UTC 基準のつもりで書くと6時間ずれるため注意
- `SqliteBackupJob` — 毎日 3:00 JST に `production.sqlite3` を gzip 圧縮して S3 の `backups/sqlite/` へアップロード。同日に複数回実行すると同名ファイルで上書き。30 日より古いファイルは自動削除。
- 手動実行: `bin/kamal app exec --interactive --reuse "bin/rails runner 'SqliteBackupJob.perform_now'"`

## テストの規約

- `describe`/`it` のラベルは日本語
- factory_bot 未使用。`User.create!` などで直接作成
- request spec の認証: `sign_in_as(user, password:)` ヘルパー（`spec/support/authentication_helper.rb`）
- system spec のドライバ: rack_test（JS 不要な操作のみテスト対象。Trix エディタへの入力は対象外）

## i18n

デフォルトロケール `:ja`、タイムゾーン `Tokyo`。バリデーションメッセージの日本語訳は `config/locales/ja.yml`。
