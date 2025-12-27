# =============================================================================
# Identity Providers
# =============================================================================

# -----------------------------------------------------------------------------
# Google Identity Provider
# -----------------------------------------------------------------------------
resource "keycloak_oidc_google_identity_provider" "google" {
  count = var.google_idp_enabled ? 1 : 0

  realm         = keycloak_realm.realm.id
  client_id     = var.google_idp_client_id
  client_secret = var.google_idp_client_secret

  trust_email = true
  store_token = false
  sync_mode   = "IMPORT"

  # Configure first broker login flow
  first_broker_login_flow_alias = keycloak_authentication_flow.auto_create_user_first_login.alias

  accepts_prompt_none_forward_from_client = false
  disable_user_info                       = false
  default_scopes                          = "openid profile email"

  extra_config = {
    # "offlineAccess"                       = "false"
    # "acceptsPromptNoneForwardFromClient"  = "false"
    # "disableUserInfo"                     = "false"
    "filteredByClaim"                     = "false"
    "caseSensitiveOriginalUsername"       = "false"
    "prompt"                              = "consent select_account"
    # "defaultScope"                        = "openid profile email"
  }
}

# =============================================================================
# Identity Provider Mappers
# =============================================================================

# -----------------------------------------------------------------------------
# Google Email Mapper
# -----------------------------------------------------------------------------
resource "keycloak_attribute_importer_identity_provider_mapper" "google_email" {
  count = var.google_idp_enabled ? 1 : 0

  realm                   = keycloak_realm.realm.id
  name                    = "google-email-mapper"
  identity_provider_alias = keycloak_oidc_google_identity_provider.google[0].alias
  user_attribute          = "email"
  claim_name              = "email"

  extra_config = {
    syncMode = "IMPORT"
  }
}

# -----------------------------------------------------------------------------
# Google Given Name Mapper
# -----------------------------------------------------------------------------
resource "keycloak_attribute_importer_identity_provider_mapper" "google_given_name" {
  count = var.google_idp_enabled ? 1 : 0

  realm                   = keycloak_realm.realm.id
  name                    = "google-given-name-mapper"
  identity_provider_alias = keycloak_oidc_google_identity_provider.google[0].alias
  user_attribute          = "firstName"
  claim_name              = "given_name"

  extra_config = {
    syncMode = "IMPORT"
  }
}

# -----------------------------------------------------------------------------
# Google Family Name Mapper
# -----------------------------------------------------------------------------
resource "keycloak_attribute_importer_identity_provider_mapper" "google_family_name" {
  count = var.google_idp_enabled ? 1 : 0

  realm                   = keycloak_realm.realm.id
  name                    = "google-family-name-mapper"
  identity_provider_alias = keycloak_oidc_google_identity_provider.google[0].alias
  user_attribute          = "lastName"
  claim_name              = "family_name"

  extra_config = {
    syncMode = "IMPORT"
  }
}
