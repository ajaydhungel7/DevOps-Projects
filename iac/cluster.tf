resource "azurerm_user_assigned_identity" "aks_identity" {
  name                = "aks-identity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "DevOpsproject-cluster1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "devopsproject"
  kubernetes_version  = "1.29.2"  # Adjust this to your desired version

  default_node_pool {
    name                = "agentpool"
    node_count          = 2
    vm_size             = "Standard_DS2_v2"
    os_disk_size_gb     = 128
    os_disk_type        = "Managed"
    vnet_subnet_id      = azurerm_subnet.aks_subnet.id  # Use the specified subnet
    type                = "VirtualMachineScaleSets"
    enable_auto_scaling = false
    
  }

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.aks_identity.id]
  }

    network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
    service_cidr      = "10.1.0.0/16"  # Non-overlapping service CIDR
    dns_service_ip    = "10.1.0.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  # Disable Azure AD integration

  # Enable local accounts
  local_account_disabled = false

  # Enable Kubernetes RBAC
  role_based_access_control_enabled = true

  tags = {
    Environment = "Development"
  }
}

# Grant AKS cluster managed identity access to ACR
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Grant AKS cluster managed identity the necessary permissions
resource "azurerm_role_assignment" "aks_identity_contributor" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.aks_identity.principal_id
}

# Output the AKS cluster name
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

#