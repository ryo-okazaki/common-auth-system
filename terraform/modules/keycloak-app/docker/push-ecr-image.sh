#!/bin/bash
set -e

REGION="ap-northeast-1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "ECRにログイン..."
aws ecr get-login-password --region "${REGION}" | docker login --username AWS --password-stdin "${ECR_REPOSITORY_URL%%/*}"

echo "カスタムイメージをビルド..."
docker build \
  -t "${ECR_REPOSITORY_URL}:${KEYCLOAK_VERSION}" \
  -f "${SCRIPT_DIR}/Dockerfile" \
  "${SCRIPT_DIR}"

echo "プッシュ..."
docker push "${ECR_REPOSITORY_URL}:${KEYCLOAK_VERSION}"

echo "完了!"
