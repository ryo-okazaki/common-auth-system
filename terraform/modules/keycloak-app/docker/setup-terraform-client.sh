#!/bin/bash
set -e

KEYCLOAK_URL="${KEYCLOAK_URL:-http://localhost:8080}"
ADMIN_USER="${KEYCLOAK_ADMIN:-admin}"
ADMIN_PASSWORD="${KEYCLOAK_ADMIN_PASSWORD}"
TERRAFORM_CLIENT_ID="terraform-admin"
TERRAFORM_CLIENT_SECRET="${TERRAFORM_CLIENT_SECRET}"

if [ -z "$ADMIN_PASSWORD" ] || [ -z "$TERRAFORM_CLIENT_SECRET" ]; then
  echo "Error: ADMIN_PASSWORD and TERRAFORM_CLIENT_SECRET are required"
  echo "Usage: ADMIN_PASSWORD=xxx TERRAFORM_CLIENT_SECRET=yyy $0"
  exit 1
fi

echo "=== Keycloak Terraform Client Setup ==="

echo "Authenticating to Keycloak..."
/opt/keycloak/bin/kcadm.sh config credentials \
  --server "$KEYCLOAK_URL" \
  --realm master \
  --user "$ADMIN_USER" \
  --password "$ADMIN_PASSWORD"

EXISTING_CLIENT=$(/opt/keycloak/bin/kcadm.sh get clients -r master -q clientId="$TERRAFORM_CLIENT_ID" --fields id 2>/dev/null | grep -o '"id"' || true)

if [ -n "$EXISTING_CLIENT" ]; then
  echo "Client '$TERRAFORM_CLIENT_ID' already exists. Skipping creation."
else
  echo "Creating Terraform client..."
  /opt/keycloak/bin/kcadm.sh create clients -r master \
    -s clientId="$TERRAFORM_CLIENT_ID" \
    -s name="Terraform Admin Client" \
    -s enabled=true \
    -s clientAuthenticatorType=client-secret \
    -s secret="$TERRAFORM_CLIENT_SECRET" \
    -s serviceAccountsEnabled=true \
    -s standardFlowEnabled=false \
    -s implicitFlowEnabled=false \
    -s directAccessGrantsEnabled=false \
    -s publicClient=false \
    -s protocol=openid-connect

  echo "Client created."
fi

echo "Assigning roles to service account..."
/opt/keycloak/bin/kcadm.sh add-roles \
  -r master \
  --uusername "service-account-$TERRAFORM_CLIENT_ID" \
  --cclientid master-realm \
  --rolename manage-realm \
  --rolename manage-clients \
  --rolename manage-users \
  --rolename manage-identity-providers \
  --rolename manage-events

echo "Assigning realm role to service account..."
/opt/keycloak/bin/kcadm.sh add-roles \
  -r master \
  --uusername "service-account-$TERRAFORM_CLIENT_ID" \
  --rolename admin

echo "=== Setup Complete ==="
