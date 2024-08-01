provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "DevOpsProject-rg"
  location = "canadacentral"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "public_ip" {
  name                = "publicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_user_assigned_identity" "vm_identity" {
  name                = "VM-identity"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_role_assignment" "vm_identity_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.vm_identity.principal_id
}

resource "azurerm_role_assignment" "aks_user_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Azure Kubernetes Service Cluster Admin Role" 
  principal_id         = azurerm_user_assigned_identity.vm_identity.principal_id
}

resource "azurerm_role_assignment" "acr_pull_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "AcrPull" 
  principal_id         = azurerm_user_assigned_identity.vm_identity.principal_id
}

resource "azurerm_role_assignment" "acr_push_role" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "AcrPush" 
  principal_id         = azurerm_user_assigned_identity.vm_identity.principal_id
}

resource "azurerm_container_registry" "acr" {
  name                = "devopsprojectlambtonregistry"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  admin_enabled       = false
}

resource "azurerm_role_assignment" "acr_admin_role" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "Owner"
  principal_id         = azurerm_user_assigned_identity.vm_identity.principal_id
  skip_service_principal_aad_check = true
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "github-runner-vm-second"
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  size                  = "Standard_B1s"
  admin_username        = "azureuser"
  network_interface_ids = [azurerm_network_interface.nic.id]
   identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.vm_identity.id]
  }
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}
resource "null_resource" "run_ansible_playbook" {
  
  provisioner "local-exec" {
    command = <<EOT
      ansible-playbook -i "${azurerm_public_ip.public_ip.ip_address}," --private-key ~/.ssh/id_rsa -u azureuser ansible-playbook.yaml
    EOT
  }

  triggers = {
    public_ip = azurerm_public_ip.public_ip.ip_address
    playbook_hash = filemd5("ansible-playbook.yaml")
  }
}

output "public_ip" {
  value = azurerm_public_ip.public_ip.ip_address
}