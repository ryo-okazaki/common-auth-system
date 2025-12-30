# app-authentication

## 概要

複数のアプリケーションで使用できるSSO（シングルサインオン）認証基盤です。KeycloakをベースとしたID管理システムで、Terraformでインフラとアプリケーション設定の両方を管理します。

## 主な機能

- **SSO（シングルサインオン）**: 複数のアプリケーション間でアカウントを共有
- **OAuth 2.0 / OpenID Connect**: 標準プロトコルによる認証
- **Google OAuth連携**: Googleアカウントでのログイン
- **ユーザー管理**: アカウント登録、メール検証、パスワードリセット
- **クライアント管理**: アプリケーションごとのクライアント設定
- **カスタマイズ可能**: Realm、Client、Identity Provider等をコードで管理

## 技術スタック

- **Keycloak**: 26.x（認証・認可サーバー）
- **Terraform**: >= 1.3（インフラ管理 + Keycloak設定管理）
- **AWS ECS (Fargate)**: Keycloakコンテナ実行環境
- **AWS RDS (PostgreSQL)**: Keycloakデータベース
- **AWS SES**: メール送信
- **Docker Compose**: ローカル開発環境

## 前提条件

### 必須ツール

- Terraform >= 1.3
- AWS CLI >= v2.13
- Docker & Docker Compose（ローカル開発時）

### 必要な権限

- **PowerUser** 権限
- **Assume Role設定**: AWS DNSアカウントと各環境用のAWSアカウント間でのAssumeRole

## セットアップ

### ローカル開発環境

Docker Composeを使用してローカルでKeycloakを起動できます。

#### 1. 環境変数設定

`.env.sample` から `.env` を作成してください。

```bash
cp .env.sample .env
```

#### 2. Keycloak起動

```bash
make up
```

Keycloakは `http://localhost:8080` で起動します。

- 管理コンソール: `http://localhost:8080/admin`
- デフォルト管理者: `admin` / `admin` (`.env`で設定)

#### 3. Keycloak停止

```bash
make down
```

### AWS環境へのデプロイ

Terraformを使用してAWS上にKeycloakインフラとアプリケーション設定をデプロイします。

#### デプロイ順序

1. **インフラ構築**: VPC、RDS、ECS等のインフラリソースを作成
2. **Keycloak設定**: Realm、Client、Identity Provider等のアプリケーション設定を適用

#### 1. インフラ構築

##### Backend設定

Remote Backendを使用する場合、`{環境名}.tfbackend.sample` から `{環境名}.tfbackend` を作成してください。

```bash
cd terraform/environments/development/infrastructure
cp development.tfbackend.sample development.tfbackend
```

###### Backend設定パラメータ

| パラメータ | 説明 | 例 |
|----------|------|-----|
| `bucket` | Terraform State管理用S3バケット名 | `develop.auth.tf-state-bucket` |
| `key` | State ファイルのパス | `infrastructure/terraform.tfstate` |
| `region` | AWSリージョン | `ap-northeast-1` |
| `encrypt` | State ファイルの暗号化 | `true` |
| `profile` | AWSプロファイル名 | `auth-app-develop-admin` |

##### 環境変数設定

`terraform.tfvars.sample` から `terraform.tfvars` を作成し、環境に応じた値を設定してください。

```bash
cd terraform/environments/development/infrastructure
cp terraform.tfvars.sample terraform.tfvars
```

###### インフラ環境変数一覧

| 変数名 | 説明 | 例 |
|--------|------|-----|
| `environment` | 環境名 | `dev` |
| `region` | AWSリージョン | `ap-northeast-1` |
| `aws_profile_auth` | 認証アプリ用AWSプロファイル | `auth-app-develop-admin` |
| `aws_profile_network` | ネットワーク管理用AWSプロファイル | `network-admin` |
| `aws_profile_shared` | 共有リソース管理用AWSプロファイル | `shared-admin` |
| `dns_account_assume_role` | DNS管理アカウントのAssumeRole ARN | `arn:aws:iam::xxxx:role/TerraformDNSDelegationRole` |
| `vpc_cidr` | VPC CIDR ブロック | `10.0.0.0/16` |
| `availability_zones` | 使用するAZ | `["ap-northeast-1a", "ap-northeast-1c"]` |
| `domain_name` | Keycloakドメイン名 | `dev.auth.ryo-okazaki.com` |
| `parent_domain_name` | 親ドメイン名 | `ryo-okazaki.com` |
| `mail_service_name` | メールサービス名 | `common-auth-system-mail` |
| `db_instance_class` | RDSインスタンスクラス | `db.t3.micro` |
| `db_multi_az` | RDS Multi-AZ | `false` |
| `db_password` | データベースパスワード | `Password123!` |
| `db_admin_password` | 管理者パスワード | `AdminPassword123!` |
| `keycloak_image_tag` | Keycloakイメージタグ | `latest` |
| `keycloak_cpu` | ECSタスクCPU | `512` |
| `keycloak_memory` | ECSタスクメモリ（MB） | `1024` |
| `keycloak_desired_count` | ECSサービスタスク数 | `1` |

##### Terraform実行

```bash
# 初期化
make tf-init-dev

# プラン確認
make tf-plan-dev

# 適用
make tf-apply-dev
```

#### 2. Keycloak設定

インフラ構築後、Keycloakアプリケーション設定を適用します。

##### Backend設定

```bash
cd terraform/environments/development/keycloak
cp development.tfbackend.sample development.tfbackend
```

Backend設定パラメータは前述のインフラと同様です。`key` のみ異なります。

| パラメータ | 説明 | 例 |
|----------|------|-----|
| `key` | State ファイルのパス | `keycloak-config/terraform.tfstate` |

##### 環境変数設定

```bash
cd terraform/environments/development/keycloak
cp terraform.tfvars.sample terraform.tfvars
```

###### Keycloak設定環境変数一覧

| 変数名 | 説明 | 例 |
|--------|------|-----|
| `keycloak_admin_client_id` | Terraform管理用クライアントID | `terraform-admin` |
| `keycloak_admin_client_secret` | Terraform管理用クライアントシークレット | `xxxxxxxxxxxx` |
| `keycloak_url` | KeycloakサーバーURL | `https://dev.auth.ryo-okazaki.com` |
| `realm_for_auth` | 認証に使用するRealm | `master` |
| `realm_name` | 作成するRealm名 | `common-auth-system` |
| `smtp_host` | SMTPホスト（SES） | `email-smtp.ap-northeast-1.amazonaws.com` |
| `smtp_port` | SMTPポート | `587` |
| `smtp_from` | メール送信元アドレス | `noreply@dev.auth.ryo-okazaki.com` |
| `todo_backend_client_secret` | ToDoバックエンドクライアントシークレット | `secret` |
| `todo_frontend_client_url` | ToDoフロントエンドURL | `https://dev.todo-app.ryo-okazaki.com` |
| `google_idp_client_id` | Google OAuth クライアントID | `xxxxxxxxxxxx.apps.googleusercontent.com` |
| `google_idp_client_secret` | Google OAuth クライアントシークレット | `GOCSPX-xxxxxxxxxxxx` |

##### Terraform実行

```bash
# 初期化
make tf-init-kc-dev

# プラン確認
make tf-plan-kc-dev

# 適用
make tf-apply-kc-dev
```

## 認証フロー

1. ユーザーがアプリケーション（例: todo-app-next）でログインボタンをクリック
2. アプリケーションがKeycloakログイン画面へリダイレクト
3. ユーザーが認証情報を入力（またはGoogle OAuth選択）
4. Keycloakが認証成功後、認可コードをアプリケーションへ返却
5. アプリケーションが認可コードをトークンに交換
6. アプリケーションがアクセストークンを使ってAPIを呼び出す

## 他サービスとの連携方法

### ToDoアプリでの利用例

ToDoアプリケーション（`todo-app-next` および `todo-app-express`）では以下のように連携します。

#### フロントエンド（todo-app-next）

- Keycloak JavaScript Adapter（`keycloak-js`）を使用
- クライアントID: `todo-frontend-client`
- Realm: `common-auth-system`

#### バックエンド（todo-app-express）

- JWT トークン検証（`jwks-rsa`）を使用
- クライアントID: `todo-backend-client`
- Keycloak公開鍵を使用してトークンを検証

## セキュリティ考慮事項

- **HTTPS通信**: 本番環境では必ずHTTPS通信を使用
- **クライアントシークレット**: 機密情報は環境変数またはSecrets Managerで管理
- **トークン有効期限**: アクセストークンの有効期限は短く設定（デフォルト5分）
- **パスワードポリシー**: 強固なパスワードポリシーを設定
- **メール検証**: ユーザー登録時のメールアドレス検証を有効化

## Keycloak設定エクスポート

ローカル環境でKeycloak設定をエクスポートできます。

```bash
# Realm設定をエクスポート
make export-settings

# 詳細設定をエクスポート
make export-settings-details
```

エクスポートされた設定は `keycloak-exports/` に保存されます。

## ドキュメント

詳細なドキュメントは以下を参照してください。

- [インフラ構成](./docs/infra/)
- [Keycloak設定](./docs/keycloak/)

## 関連リポジトリ

- [todo-app-infrastructure](../todo-app-infrastructure): ToDoアプリインフラ（Terraform）
- [todo-app-next](../todo-app-next): ToDoアプリフロントエンド（Next.js）
- [todo-app-express](../todo-app-express): ToDoアプリバックエンド（Express）
