#!/bin/bash

set -e

AWS_PROFILE=""
AWS_ACCOUNT_ID=""

REPO=""

echo "ECRへのプッシュを開始します..."
# 1. ECRにログイン
aws ecr get-login-password --region ap-northeast-1 --profile ${AWS_PROFILE} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
echo "ログインに成功しました。"

echo "イメージの取得を開始します..."
docker pull quay.io/keycloak/keycloak:26.0
echo "イメージの取得に成功しました。"

echo "イメージのタグ付けを開始します。"
docker tag quay.io/keycloak/keycloak:26.0 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${REPO}:26.0
echo "イメージのビルドに成功しました。"

echo "Backend用ECRリポジトリへのプッシュを開始します..."
# 3. Push!
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/${REPO}:26.0
echo "Backend用ECRリポジトリへのプッシュに成功しました。"

echo "all done!"
