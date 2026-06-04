terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "environment_name" {
  type        = string
  description = "Name prefix for resources"
}

variable "resource_group_name" {
  type        = string
  description = "Existing resource group name"
}

variable "location" {
  type        = string
  description = "Azure region"
}

variable "app_service_plan_sku" {
  type        = string
  description = "Linux App Service Plan SKU"
}

variable "env_type" {
  type        = string
  description = "Environment type"
}

variable "enable_storage" {
  type        = bool
  description = "Whether to deploy optional storage"
}

variable "department" {
  type        = string
  description = "Department tag"
}

variable "cost_center" {
  type        = string
  description = "Cost center tag"
}

resource "random_string" "suffix" {
  length  = 5
  special = false
  upper   = false
}

locals {
  safe_name = replace(lower(var.environment_name), "_", "-")
  common_tags = {
    managedBy       = "azure-deployment-environments"
    environment     = var.env_type
    department      = var.department
    costCenter      = var.cost_center
    pattern         = "webapp-terraform-demo"
    templateVersion = "1.0"
  }
}

resource "azurerm_service_plan" "this" {
  name                = "asp-${local.safe_name}-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.app_service_plan_sku
  tags                = local.common_tags
}

resource "azurerm_linux_web_app" "this" {
  name                = "app-${local.safe_name}-${random_string.suffix.result}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.this.id
  https_only          = true
  tags                = local.common_tags

  site_config {
    always_on = false
    application_stack {
      node_version = "18-lts"
    }
  }

  app_settings = {
    ENVIRONMENT = var.env_type
    DEPARTMENT  = var.department
  }
}

resource "azurerm_storage_account" "this" {
  count                    = var.enable_storage ? 1 : 0
  name                     = "st${replace(local.safe_name, "-", "")}${random_string.suffix.result}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.common_tags
}

output "web_app_url" {
  value = "https://${azurerm_linux_web_app.this.default_hostname}"
}

output "service_plan_name" {
  value = azurerm_service_plan.this.name
}

output "storage_account_name" {
  value = var.enable_storage ? azurerm_storage_account.this[0].name : "not-deployed"
}
