# =============================================================================
# Client Scopes
# =============================================================================

# -----------------------------------------------------------------------------
# Backend Audience Scope
# This scope adds the backend client to the "aud" claim of access tokens
# -----------------------------------------------------------------------------
resource "keycloak_openid_client_scope" "todo_backend_audience" {
  realm_id               = keycloak_realm.realm.id
  name                   = "todo-backend-audience"
  description            = "Audience mapper for backend"
  include_in_token_scope = false
  gui_order              = 0
}

# Audience Protocol Mapper for Backend
resource "keycloak_openid_audience_protocol_mapper" "todo_backend_audience_mapper" {
  realm_id        = keycloak_realm.realm.id
  client_scope_id = keycloak_openid_client_scope.todo_backend_audience.id
  name            = "todo-backend-audience"

  included_client_audience = keycloak_openid_client.todo_backend.client_id

  add_to_id_token     = false
  add_to_access_token = true
}

# =============================================================================
# Note: The following scopes (email, profile) are built-in scopes in Keycloak.
# They are created automatically when a realm is created.
# The JSON configuration shows custom protocol mappers, but these are also
# typically created by default in Keycloak.
#
# If you need to customize the built-in email/profile scopes, you would need
# to use the keycloak_openid_client_scope data source to reference them and
# potentially add additional protocol mappers.
#
# The built-in scopes include:
# - email (with email and email_verified mappers)
# - profile (with full_name, family_name, given_name, username mappers)
# - roles
# - web-origins
# - acr
# - basic
# =============================================================================
