# =============================================================================
# Authentication Flows
# =============================================================================

# -----------------------------------------------------------------------------
# Auto Create User First Login Flow
# This flow handles the first broker login with an identity provider
# when the user's account is not yet linked to any Keycloak account
# -----------------------------------------------------------------------------
resource "keycloak_authentication_flow" "auto_create_user_first_login" {
  realm_id    = keycloak_realm.realm.id
  alias       = "auto-create-user-first-login"
  description = "Actions taken after first broker login with identity provider account, which is not yet linked to any Keycloak account"
  provider_id = "basic-flow"
}

# -----------------------------------------------------------------------------
# Execution 1: Review Profile (DISABLED)
# -----------------------------------------------------------------------------
resource "keycloak_authentication_execution" "idp_review_profile" {
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.auto_create_user_first_login.alias
  authenticator     = "idp-review-profile"
  requirement       = "DISABLED"
  priority          = 10
}

resource "keycloak_authentication_execution_config" "idp_review_profile_config" {
  realm_id     = keycloak_realm.realm.id
  execution_id = keycloak_authentication_execution.idp_review_profile.id
  alias        = "auto-create-user-first-login review profile config"

  config = {
    "update.profile.on.first.login" = "on"
  }
}

# -----------------------------------------------------------------------------
# Execution 2: Create User If Unique (ALTERNATIVE)
# -----------------------------------------------------------------------------
resource "keycloak_authentication_execution" "idp_create_user_if_unique" {
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.auto_create_user_first_login.alias
  authenticator     = "idp-create-user-if-unique"
  requirement       = "ALTERNATIVE"
  priority          = 20
}

resource "keycloak_authentication_execution_config" "idp_create_user_if_unique_config" {
  realm_id     = keycloak_realm.realm.id
  execution_id = keycloak_authentication_execution.idp_create_user_if_unique.id
  alias        = "auto-create-user-first-login create unique user config"

  config = {
    "require.password.update.after.registration" = "false"
  }
}

# -----------------------------------------------------------------------------
# Execution 3: Confirm Link (ALTERNATIVE)
# -----------------------------------------------------------------------------
resource "keycloak_authentication_execution" "idp_confirm_link" {
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.auto_create_user_first_login.alias
  authenticator     = "idp-confirm-link"
  requirement       = "ALTERNATIVE"
  priority          = 30
}

# -----------------------------------------------------------------------------
# Execution 4: Email Verification (ALTERNATIVE)
# -----------------------------------------------------------------------------
resource "keycloak_authentication_execution" "idp_email_verification" {
  realm_id          = keycloak_realm.realm.id
  parent_flow_alias = keycloak_authentication_flow.auto_create_user_first_login.alias
  authenticator     = "idp-email-verification"
  requirement       = "ALTERNATIVE"
  priority          = 40
}
