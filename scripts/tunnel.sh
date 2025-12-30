#!/bin/bash
# scripts/tunnel.sh

# 事前に infrastructure レイヤーで作成した値を指定
ENV="dev"
#REMOTE_ALB_DNS=$(aws ssm get-parameter --name "/$ENV/keycloak/alb_dns_name" --query "Parameter.Value" --output text)
REMOTE_ALB_DNS=""
# 中継用インスタンスのID（または ECS Task ID）
#BASTION_INSTANCE_ID=$(aws ssm get-parameter --name "/$ENV/network/bastion_instance_id" --query "Parameter.Value" --output text)
BASTION_INSTANCE_ID=""

echo "Starting tunnel to $REMOTE_ALB_DNS:8080 via $BASTION_INSTANCE_ID..."

aws ssm start-session \
    --target "$BASTION_INSTANCE_ID" \
    --document-name AWS-StartPortForwardingSessionToRemoteHost \
    --parameters "{
        \"portNumber\":[\"8080\"],
        \"localPortNumber\":[\"8080\"],
        \"host\":[\"$REMOTE_ALB_DNS\"]
    }"
