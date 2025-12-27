# =============================================================================
# Realm Configuration Variables
# =============================================================================

variable "realm_name" {
  description = "The name of the realm"
  type        = string
}

variable "realm_enabled" {
  description = "Whether the realm is enabled"
  type        = bool
  default     = true
}

# variable "realm_frontend_url" {
#   description = "The frontend URL for the realm"
#   type        = string
# }

variable "ssl_required" {
  description = "SSL required setting (none, external, all)"
  type        = string
  default     = "external"
}

variable "registration_allowed" {
  description = "Whether user registration is allowed"
  type        = bool
  default     = true
}

variable "remember_me" {
  description = "Whether remember me is enabled"
  type        = bool
  default     = true
}

variable "verify_email" {
  description = "Whether email verification is required"
  type        = bool
  default     = true
}

variable "login_with_email_allowed" {
  description = "Whether login with email is allowed"
  type        = bool
  default     = true
}

variable "duplicate_emails_allowed" {
  description = "Whether duplicate emails are allowed"
  type        = bool
  default     = false
}

variable "reset_password_allowed" {
  description = "Whether password reset is allowed"
  type        = bool
  default     = true
}

variable "edit_username_allowed" {
  description = "Whether username editing is allowed"
  type        = bool
  default     = false
}

# =============================================================================
# Token Lifespan Variables
# =============================================================================

variable "access_token_lifespan" {
  description = "Access token lifespan in seconds (Go duration string for Terraform)"
  type        = string
  default     = "5m"
}

variable "sso_session_idle_timeout" {
  description = "SSO session idle timeout (Go duration string)"
  type        = string
  default     = "30m"
}

variable "sso_session_max_lifespan" {
  description = "SSO session max lifespan (Go duration string)"
  type        = string
  default     = "10h"
}

variable "access_code_lifespan" {
  description = "Access code lifespan (Go duration string)"
  type        = string
  default     = "1m"
}

# =============================================================================
# SMTP Configuration Variables
# =============================================================================

variable "smtp_host" {
  description = "SMTP server host"
  type        = string
}

variable "smtp_port" {
  description = "SMTP server port"
  type        = string
}

variable "smtp_from" {
  description = "SMTP from address"
  type        = string
}

variable "smtp_from_display_name" {
  description = "SMTP from display name"
  type        = string
  default     = "Microservice App"
}

variable "smtp_starttls" {
  description = "Whether to use STARTTLS"
  type        = bool
  default     = false
}

variable "smtp_ssl" {
  description = "Whether to use SSL"
  type        = bool
  default     = false
}

variable "smtp_auth_enabled" {
  description = "Whether SMTP authentication is enabled"
  type        = bool
  default     = false
}

variable "smtp_auth_username" {
  description = "SMTP authentication username (required if smtp_auth_enabled is true)"
  type        = string
  default     = ""
}

variable "smtp_auth_password" {
  description = "SMTP authentication password (required if smtp_auth_enabled is true)"
  type        = string
  default     = ""
  sensitive   = true
}

# =============================================================================
# Backend Client Variables
# =============================================================================

variable "todo_backend_client_id" {
  description = "The client ID for the backend client"
  type        = string
  default     = "todo-backend-client"
}

variable "todo_backend_client_name" {
  description = "The name of the backend client"
  type        = string
  default     = "ToDo Backend Client"
}

variable "todo_backend_client_secret" {
  description = "The client secret for the backend client"
  type        = string
  sensitive   = true
}

# =============================================================================
# Frontend Client Variables
# =============================================================================

variable "todo_frontend_client_id" {
  description = "The client ID for the frontend client"
  type        = string
  default     = "todo-frontend-client"
}

variable "todo_frontend_client_name" {
  description = "The name of the frontend client"
  type        = string
  default     = "ToDo Frontend Client"
}

variable "todo_frontend_client_url" {
  description = "The URL of the frontend client"
  type        = string
}

# =============================================================================
# Google Identity Provider Variables
# =============================================================================

variable "google_idp_enabled" {
  description = "Whether Google IdP is enabled"
  type        = bool
  default     = true
}

variable "google_idp_client_id" {
  description = "Google OAuth client ID"
  type        = string
}

variable "google_idp_client_secret" {
  description = "Google OAuth client secret"
  type        = string
  sensitive   = true
}
