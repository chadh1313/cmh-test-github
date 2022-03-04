#################################################################
# Terraform template that will deploy:
#    * 2 Centos VMs on Microsoft Azure
#
# Version: 2.4
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2020.
#
#################################################################

#########################################################
# Define the Azure provider
#########################################################
provider "azurerm" {
  #azurerm_subnet uses address_prefixes from 2.9.0
  #so pin this template to >= 2.9.0
  version = ">= 2.9.0"
  features {}
}

#########################################################
# Helper module for tagging
#########################################################
module "camtags" {
  source = "../Modules/camtags"
}

#########################################################
# Define the variables
#########################################################
variable "azure_region" {
  description = "Azure region to deploy infrastructure resources"
  default     = "East US"
}

variable "name_prefix" {
  description = "Prefix of names for Azure resources"
  default     = "twonode"
}

variable "admin_user" {
  description = "Name of an administrative user to be created in virtual machine in this deployment"
  default     = "ibmadmin"
}

variable "admin_user_password" {
  description = "Password of the newly created administrative user"
}

variable "user_public_key" {
  description = "Public SSH key used to connect to the virtual machine"
}

variable "instance_type" {
  description = "Standard_A2"
}

#########################################################
# Deploy the network resources
#########################################################
resource "random_id" "default" {
  byte_length = "4"
}

resource "azurerm_resource_group" "default" {
  name     = "${var.name_prefix}-${random_id.default.hex}-rg"
  location = var.azure_region
  tags     = module.camtags.tagsmap
}

resource "azurerm_virtual_network" "default" {
  name                = "${var.name_prefix}-${random_id.default.hex}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.default.name

  tags = {
    environment = "Terraform Basic VM"
  }
}

resource "azurerm_subnet" "vm" {
  name                 = "${var.name_prefix}-subnet-${random_id.default.hex}-vm"
  resource_group_name  = azurerm_resource_group.default.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "webvm" {
  name                = "${var.name_prefix}-${random_id.default.hex}-webvm-pip"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
  tags                = module.camtags.tagsmap
}

resource "azurerm_public_ip" "dbvm" {
  name                = "${var.name_prefix}-${random_id.default.hex}-dbvm-pip"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.default.name
  allocation_method   = "Static"
  tags                = module.camtags.tagsmap
}

resource "azurerm_network_security_group" "vm" {
  depends_on		  = ["azurerm_network_interface.webvm", "azurerm_network_interface.dbvm"]
  name                = "${var.name_prefix}-${random_id.default.hex}-vm-nsg"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.default.name
  tags                = module.camtags.tagsmap

  security_rule {
    name                       = "ssh-allow"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "custom-tcp-allow"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface" "webvm" {
  name                = "${var.name_prefix}-${random_id.default.hex}-webvm-nic1"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "${var.name_prefix}-${random_id.default.hex}-webvm-nic1-ipc"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.webvm.id
  }
  tags                = module.camtags.tagsmap
}

resource "azurerm_network_interface_security_group_association" "webvm" {
  depends_on		  = [azurerm_network_interface.webvm, azurerm_network_security_group.vm]
  network_interface_id      = azurerm_network_interface.webvm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

resource "azurerm_network_interface" "dbvm" {
  name                = "${var.name_prefix}-${random_id.default.hex}-dbvm-nic1"
  location            = var.azure_region
  resource_group_name = azurerm_resource_group.default.name

  ip_configuration {
    name                          = "${var.name_prefix}-${random_id.default.hex}-dbvm-nic1-ipc"
    subnet_id                     = azurerm_subnet.vm.id
    private_ip_address_allocation = "dynamic"
    public_ip_address_id          = azurerm_public_ip.dbvm.id
  }
  tags                = module.camtags.tagsmap
}

resource "azurerm_network_interface_security_group_association" "dbvm" {
  depends_on		  = [azurerm_network_interface.dbvm, azurerm_network_security_group.vm]
  network_interface_id      = azurerm_network_interface.dbvm.id
  network_security_group_id = azurerm_network_security_group.vm.id
}

#########################################################
# Deploy the storage resources
#########################################################
resource "azurerm_storage_account" "default" {
  name                     = format("st%s", random_id.default.hex)
  resource_group_name      = azurerm_resource_group.default.name
  location                 = var.azure_region
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = module.camtags.tagsmap

}

resource "azurerm_storage_container" "default" {
  name                  = "default-container"
  storage_account_name  = azurerm_storage_account.default.name
  container_access_type = "private"
}

#########################################################
# Deploy the web virtual machine resource
#########################################################
resource "azurerm_virtual_machine" "webvm" {
  depends_on			      = [azurerm_network_interface_security_group_association.webvm]
  name                  = "${var.name_prefix}-webvm"
  location              = var.azure_region
  resource_group_name   = azurerm_resource_group.default.name
  network_interface_ids = [azurerm_network_interface.webvm.id]
  vm_size               = var.instance_type

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_8-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name = "webvm-osdisk"
    caching = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.name_prefix}-webvm"
    admin_username = var.admin_user
    admin_password = var.admin_user_password
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = var.user_public_key
    }
  }

  tags             = module.camtags.tagsmap
}

#########################################################
# Deploy the db virtual machine resource
#########################################################
resource "azurerm_virtual_machine" "dbvm" {
  depends_on			      = [azurerm_network_interface_security_group_association.dbvm]
  name                  = "${var.name_prefix}-dbvm"
  location              = var.azure_region
  resource_group_name   = azurerm_resource_group.default.name
  network_interface_ids = [azurerm_network_interface.dbvm.id]
  vm_size               = var.instance_type

  storage_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "7_8-gen2"
    version   = "latest"
  }

  storage_os_disk {
    name = "dbvm-osdisk"
    caching = "ReadWrite"
    managed_disk_type = "Standard_LRS"
    create_option = "FromImage"
  }

  os_profile {
    computer_name  = "${var.name_prefix}-dbvm"
    admin_username = var.admin_user
    admin_password = var.admin_user_password
  }

  os_profile_linux_config {
    disable_password_authentication = false

    ssh_keys {
      path     = "/home/${var.admin_user}/.ssh/authorized_keys"
      key_data = var.user_public_key
    }
  }

 tags             = module.camtags.tagsmap
}

#########################################################
# Output
#########################################################
output "azure_webvm_public_ip" {
  value = azurerm_public_ip.webvm.ip_address
}

output "azure_dbvm_public_ip" {
  value = azurerm_public_ip.dbvm.ip_address
}

output "azure_webvm_private_ip" {
  value = azurerm_network_interface.webvm.private_ip_address
}

output "azure_dbvm_private_ip" {
  value = azurerm_network_interface.dbvm.private_ip_address
}

