# =============================================================================
# Keycloak Realm Configuration
# =============================================================================
# This module manages a Keycloak realm with the following components:
# - Realm settings
# - OpenID Connect clients
# - Client scopes
# - Authentication flows
# - Google Identity Provider
# =============================================================================

terraform {
  required_providers {
    keycloak = {
      source  = "keycloak/keycloak"
      version = ">= 5.0.0"
    }
  }
}

# =============================================================================
# Realm Resource
# =============================================================================

resource "keycloak_realm" "realm" {
  realm   = var.realm_name
  enabled = var.realm_enabled

  # Login settings
  registration_allowed     = var.registration_allowed
  remember_me              = var.remember_me
  verify_email             = var.verify_email
  login_with_email_allowed = var.login_with_email_allowed
  duplicate_emails_allowed = var.duplicate_emails_allowed
  reset_password_allowed   = var.reset_password_allowed
  edit_username_allowed    = var.edit_username_allowed

  # SSL settings
  ssl_required = var.ssl_required

  # Token settings
  access_token_lifespan    = var.access_token_lifespan
  sso_session_idle_timeout = var.sso_session_idle_timeout
  sso_session_max_lifespan = var.sso_session_max_lifespan
  access_code_lifespan     = var.access_code_lifespan

  # SMTP server configuration
  smtp_server {
    host              = var.smtp_host
    port              = var.smtp_port
    from              = var.smtp_from
    from_display_name = var.smtp_from_display_name
    starttls          = var.smtp_starttls
    ssl               = var.smtp_ssl

    dynamic "auth" {
      for_each = var.smtp_auth_enabled ? [1] : []
      content {
        username = var.smtp_auth_username
        password = var.smtp_auth_password
      }
    }
  }
}
