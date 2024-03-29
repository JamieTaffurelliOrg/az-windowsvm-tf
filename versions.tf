terraform {
  required_providers {
    azurerm = {
      configuration_aliases = [azurerm.logs, azurerm.images]
      source                = "hashicorp/azurerm"
      version               = "~> 3.20"
    }

    random = {
      source  = "hashicorp/random"
      version = "~> 3.3.0"
    }
  }
  required_version = "~> 1.6.0"
}
