terraform {
  required_version = ">= 1.7.1"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.91.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6.0"
    }
  }

}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
      recover_soft_deleted_secrets    = false 
    }
    log_analytics_workspace {
      permanently_delete_on_destroy   = true
    }
  }

  subscription_id = var.subscription_id
  client_id       = var.arm_client_id
  client_secret   = var.arm_client_secret 
  tenant_id       = var.aad_tenant_id
  skip_provider_registration = true
}
