# =============================================================================
# OpenID Connect Clients
# =============================================================================

# -----------------------------------------------------------------------------
# Backend Client (Confidential - Service Account)
# -----------------------------------------------------------------------------
resource "keycloak_openid_client" "todo_backend" {
  realm_id  = keycloak_realm.realm.id
  client_id = var.todo_backend_client_id
  name      = var.todo_backend_client_name
  enabled   = true

  access_type   = "CONFIDENTIAL"
  client_secret = var.todo_backend_client_secret

  # Flow settings - service account only
  standard_flow_enabled        = false
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false
  service_accounts_enabled     = true

  # Redirect URIs
  # valid_redirect_uris = ["/*"]
  # web_origins         = ["/*"]

  full_scope_allowed = true
}

# -----------------------------------------------------------------------------
# Frontend Client (Public)
# -----------------------------------------------------------------------------
resource "keycloak_openid_client" "todo_frontend" {
  realm_id  = keycloak_realm.realm.id
  client_id = var.todo_frontend_client_id
  name      = var.todo_frontend_client_name
  enabled   = true

  access_type = "PUBLIC"

  # URLs
  root_url  = var.todo_frontend_client_url
  admin_url = var.todo_frontend_client_url

  # Flow settings
  standard_flow_enabled        = true
  implicit_flow_enabled        = false
  direct_access_grants_enabled = false
  service_accounts_enabled     = false

  # Redirect URIs
  valid_redirect_uris = ["${var.todo_frontend_client_url}/*"]
  web_origins         = [var.todo_frontend_client_url]

  full_scope_allowed = true
}

# -----------------------------------------------------------------------------
# Frontend Client - Default Scopes
# -----------------------------------------------------------------------------
resource "keycloak_openid_client_default_scopes" "frontend_default_scopes" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.todo_frontend.id

  default_scopes = [
    "web-origins",
    "acr",
    "profile",
    "roles",
    "basic",
    "email",
    keycloak_openid_client_scope.todo_backend_audience.name
  ]
}

# -----------------------------------------------------------------------------
# Frontend Client - Optional Scopes
# -----------------------------------------------------------------------------
resource "keycloak_openid_client_optional_scopes" "frontend_optional_scopes" {
  realm_id  = keycloak_realm.realm.id
  client_id = keycloak_openid_client.todo_frontend.id

  optional_scopes = [
    "address",
    "phone",
    "offline_access",
    "organization",
    "microprofile-jwt"
  ]
}
