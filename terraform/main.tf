
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=3.54.0"
    }
  }
}


provider "azurerm" {  
  features {

  }
}



# Resource group
resource "azurerm_resource_group" "rg" {
  name     = "aks-tour-of-heroes"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "aks-tour-of-heroes"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  dns_prefix = "k8s-heroes"

  default_node_pool {
    name       = "default"
    vm_size    = "Standard_B4ms"
    node_count = 3
  }

  identity {
    type = "SystemAssigned"
  }

}

