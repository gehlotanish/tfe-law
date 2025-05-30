variable "medline_default_location" {
  type    = string
  default = "ussc"
}

variable "environment" {
  type = string
}

variable "azure_resource_group_name" {
  type = string
}

variable "project-name" {
  type = string
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "access_tier" {
  type    = string
  default = "Cool"
}

variable "network_rule_default_action" {
  type    = string
  default = "Deny"
}

variable "retention" {
  type    = number
  default = 15
}

variable "log_analytics_name" {
  type = string
}

variable "key_vault_name" {
  type = string
}

variable "data_lake_enabled" {
  type    = string
  default = false
}

variable "cmk_keyname" {
  type = string
}

variable "extra_storage_tags" {
  type        = map(string)
  default     = {}
  description = "List of extra tags"
}

variable "diagnostic_enabled" {
  type    = string
  default = false
}

variable "CMK_enabled" {
  type    = string
  default = false
}

variable "cors_rule" {
  type    = any
  default = []
}

variable "static_website" {
  type    = list(map(string))
  default = []
}

variable "network_rules" {
  type    = any
  default = []
}

