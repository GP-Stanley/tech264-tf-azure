# Configure the Azure provider
provider "azurerm" {
  features {}
  use_cli                         = true
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

# Reference an existing resource group
data "azurerm_resource_group" "main" {
  name = "tech264" # Replace with the actual name of your resource group
}

# Create a storage account for storing Terraform state
resource "azurerm_storage_account" "backend_sa" {
  name                     = "tfgeorgiastorageaccount" # Storage account name must be unique
  resource_group_name      = "tech264"
  location                 = "Uk South"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false
  tags = {Name="georgia"
  }
}

# Create a storage container for Terraform state files
resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.backend_sa.name   # Link to the storage account
  container_access_type = "private"                                 # Set container access to private
}

