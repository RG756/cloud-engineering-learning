# Project D 引継ぎメモ（Session 3 → Session 4）

## 完了済み: Session 1（基盤構築）

### デプロイ済みAWSリソース
- **DynamoDB テーブル**: `project-d-items`（PAY_PER_REQUEST、hash_key: id）
- **Lambda 関数**: `project-d-api`（Python 3.12、CRUD対応）
- **IAM ロール**: `project-d-lambda-role`（DynamoDB + CloudWatch Logs権限）
- **疎通確認済み**: create（201）+ list（200）成功

## 完了済み: Session 2（API構築）

### デプロイ済みAWSリソース（追加分）
- **API Gateway REST API**: `project-d-api`
- **エンドポイント**: `https://k4odvrhs06.execute-api.ap-northeast-1.amazonaws.com/prod/items`
- **Lambda Permission**: API Gateway → Lambda の呼び出し許可
- **ステージ**: `prod`

### CRUD動作検証結果
| 操作 | メソッド | パス | 結果 |
|------|----------|------|------|
| 一覧取得 | GET | /items | ✅ 200 |
| 新規作成 | POST | /items | ✅ 201 |
| 1件取得 | GET | /items/{id} | ✅ 200 |
| 更新 | PUT | /items/{id} | ✅ 200 |
| 削除 | DELETE | /items/{id} | ✅ 200 |

## 完了済み: Session 3（運用・監視）

### デプロイ済みAWSリソース（追加分）
- **CloudWatch Log Group**: `/aws/lambda/project-d-api`（Lambda用、14日保持）
- **CloudWatch Log Group**: `/aws/apigateway/project-d-api`（API Gateway用、14日保持）
- **Metric Filter**: `project-d-lambda-errors`（ログから"ERROR"を検知 → カスタムメトリクス）
- **CloudWatch Alarm**: `project-d-lambda-errors`（5分間にERROR 1回以上 → SNS通知）
- **SNS Topic + Subscription**: `project-d-alarm-topic`（メール通知先: 確認済み）
- **IAM Role**: `project-d-apigw-cloudwatch-role`（API Gateway → CloudWatch Logs書き込み用）
- **API Gateway Account**: CloudWatch連携のリージョン設定
- **API Gateway Method Settings**: 全メソッドのログ・メトリクス有効化

### Session 3で行った変更
- `lambda/index.py` — 構造化ログ（loggingモジュール）+ エラー分類（404/400/500）+ リクエストログ追加
- `lambda.tf` — `LOG_LEVEL` 環境変数追加
- `cloudwatch.tf` — 新規作成（Log Group×2、Metric Filter、SNS、Alarm）
- `iam.tf` — API Gateway → CloudWatch用IAMロール追加
- `apigateway.tf` — ステージにアクセスログ設定 + メソッド設定追加
- `variables.tf` — `alarm_email` 変数追加

### Session 3で確認した動作
- GET /items → 200 + CloudWatch Logsに[INFO]リクエストログ記録
- GET /items/this-id-does-not-exist → 404 + CloudWatch Logsに[WARNING]記録
- POST /items（壊れたJSON） → 400 + CloudWatch Logsに[WARNING]記録
- コールドスタート（~500ms）vs ウォームスタート（~2-3ms）の差を確認
- `terraform import` で既存Log GroupをTerraform管理に取り込み

### 学んだ概念
- Metric Filter: ログのテキストパターン → カスタムメトリクスに変換
- API Gatewayのアクセスログ vs Lambdaのアプリケーションログの違い
- DynamoDBキャパシティ: On-Demand（PAY_PER_REQUEST）vs Provisioned（RCU/WCU）
- WARNING（クライアントエラー）とERROR（サーバー障害）の区別が運用上重要

### 作業フォルダ
```
project-d-serverless-api/
├── main.tf          # provider (ap-northeast-1)
├── variables.tf     # aws_region, project_name, alarm_email
├── dynamodb.tf      # DynamoDB テーブル
├── iam.tf           # Lambda用 + API Gateway用 IAMロール・ポリシー
├── lambda.tf        # Lambda関数定義（LOG_LEVEL環境変数付き）
├── apigateway.tf    # API Gateway（アクセスログ + メソッド設定付き）
├── cloudwatch.tf    # Log Group×2, Metric Filter, SNS, Alarm ★Session 3で追加
├── outputs.tf       # テーブル名、関数名、ARN、APIエンドポイント
├── lambda/
│   └── index.py     # Python CRUD handler（構造化ログ + エラー分類対応）
├── payload.json     # テスト用（削除可）
├── response.json    # テスト用（削除可）
└── test_bad.json    # テスト用（削除可）
```

### 注意点
- PowerShellで curl.exe を使う際、JSONはファイル経由（`-d "@payload.json"`）が安全
- PowerShellの `Out-File -Encoding utf8` はBOM付きになる → `[System.IO.File]::WriteAllText()` を使う
- Terraformの state は `.terraform/` と `terraform.tfstate` にある（.gitignore対象）
- リソースはサーバーレスなので放置しても課金ほぼゼロ
- `terraform output -raw api_endpoint` でURLを変数に取り込むと、PowerShellのURL切れ問題を回避できる
- Lambdaが自動作成したLog Groupは `terraform import` で取り込む必要がある

---

## 次回: Session 4（仕上げ・GitHub、~1.5h）

### やること
1. コード整理・変数化・モジュール化
2. `terraform destroy` → 再構築で再現性確認
3. 英語 README + アーキテクチャ図作成
4. GitHub push + 振り返り

### ゴール
ポートフォリオとしてGitHubにpushできる状態にすること

---

## 全体進捗
- Session 1 ✅ 基盤構築（DynamoDB + Lambda + IAM）
- Session 2 ✅ API構築（API Gateway + Lambda統合 + CRUD検証）
- Session 3 ✅ 運用・監視（CloudWatch, エラーハンドリング, ログ検証）
- Session 4 ⬜ 仕上げ・GitHub（README, destroy→再構築, push）← 次回で完結！

## 環境メモ
- 作業パス: `C:\Users\ryogo\OneDrive\Documents\GitHub\cloud-engineering-learning`
- **Project D完了後にやること**: OneDrive → ローカル(`C:\Users\ryogo\Documents\GitHub\`)へフォルダ移行
- AWS profile: default / region: ap-northeast-1
- IDE: Cursor（IDEモードで作業、統合ターミナルでコマンド実行）
