# =============================================================================
# Outputs
# =============================================================================

# -----------------------------------------------------------------------------
# Realm Outputs
# -----------------------------------------------------------------------------
output "realm_id" {
  description = "The ID of the realm"
  value       = keycloak_realm.realm.id
}

output "realm_name" {
  description = "The name of the realm"
  value       = keycloak_realm.realm.realm
}

# -----------------------------------------------------------------------------
# Client Outputs
# -----------------------------------------------------------------------------
output "todo_backend_client_id" {
  description = "The Keycloak internal ID of the backend client"
  value       = keycloak_openid_client.todo_backend.id
}

output "todo_backend_client_client_id" {
  description = "The client_id of the backend client"
  value       = keycloak_openid_client.todo_backend.client_id
}

output "todo_backend_client_service_account_user_id" {
  description = "The service account user ID of the backend client"
  value       = keycloak_openid_client.todo_backend.service_account_user_id
}

output "todo_frontend_client_id" {
  description = "The Keycloak internal ID of the frontend client"
  value       = keycloak_openid_client.todo_frontend.id
}

output "todo_frontend_client_client_id" {
  description = "The client_id of the frontend client"
  value       = keycloak_openid_client.todo_frontend.client_id
}

# -----------------------------------------------------------------------------
# Client Scope Outputs
# -----------------------------------------------------------------------------
output "todo_backend_audience_scope_id" {
  description = "The ID of the backend audience scope"
  value       = keycloak_openid_client_scope.todo_backend_audience.id
}

output "todo_backend_audience_scope_name" {
  description = "The name of the backend audience scope"
  value       = keycloak_openid_client_scope.todo_backend_audience.name
}

# -----------------------------------------------------------------------------
# Authentication Flow Outputs
# -----------------------------------------------------------------------------
output "auto_create_user_flow_id" {
  description = "The ID of the auto-create-user-first-login flow"
  value       = keycloak_authentication_flow.auto_create_user_first_login.id
}

output "auto_create_user_flow_alias" {
  description = "The alias of the auto-create-user-first-login flow"
  value       = keycloak_authentication_flow.auto_create_user_first_login.alias
}

# -----------------------------------------------------------------------------
# Identity Provider Outputs
# -----------------------------------------------------------------------------
output "google_idp_alias" {
  description = "The alias of the Google identity provider"
  value       = var.google_idp_enabled ? keycloak_oidc_google_identity_provider.google[0].alias : null
}

output "google_idp_internal_id" {
  description = "The internal ID of the Google identity provider"
  value       = var.google_idp_enabled ? keycloak_oidc_google_identity_provider.google[0].internal_id : null
}
