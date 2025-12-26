#!/bin/bash
set -e

REGION="ap-northeast-1"

echo "ECRにログイン..."
aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ECR_REPOSITORY_URL%%/*}"

echo "イメージを取得..."
docker pull "quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}"

echo "タグ付け..."
docker tag "quay.io/keycloak/keycloak:${KEYCLOAK_VERSION}" "${ECR_REPOSITORY_URL}:${KEYCLOAK_VERSION}"

echo "プッシュ..."
docker push "${ECR_REPOSITORY_URL}:${KEYCLOAK_VERSION}"

echo "完了!"
