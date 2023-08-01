
provider "azurerm" {
  features {

  }
}

variable "flux_aks_name" {
  type = string
  default = "flux-aks-tour-of-heroes"
}


# Resource group
resource "azurerm_resource_group" "flux_rg" {
  name     = "flux-aks-tour-of-heroes-demo"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "flux_aks" {
  name                = var.flux_aks_name
  location            = azurerm_resource_group.flux_rg.location
  resource_group_name = azurerm_resource_group.flux_rg.name

  dns_prefix = "flux-k8s-heroes"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

}

variable "argocd_aks_name" {
  type = string
  default = "argo-aks-tour-of-heroes"
}


# Resource group
resource "azurerm_resource_group" "argo_rg" {
  name     = "argo-aks-tour-of-heroes-demo"
  location = "West Europe"
}

resource "azurerm_kubernetes_cluster" "argo_aks" {
  name                = var.argocd_aks_name
  location            = azurerm_resource_group.argo_rg.location
  resource_group_name = azurerm_resource_group.argo_rg.name

  dns_prefix = "argo-k8s-heroes"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

}