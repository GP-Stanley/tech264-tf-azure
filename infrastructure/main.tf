# Create the VNet with Two Subnets
provider "azurerm" {
  features {}
  use_cli                         = true
  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

# Create a VNet
resource "azurerm_virtual_network" "tech264_georgia_vnet" {
  name                = "tech264_georgia_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = "UK South"
  resource_group_name = "tech264"
}

# Create two subnets within the VNet
# Create public subnet
resource "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = "tech264"
  virtual_network_name = azurerm_virtual_network.tech264_georgia_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# create private subnet
resource "azurerm_subnet" "private_subnet" {
  name                 = "private-subnet"
  resource_group_name  = "tech264"
  virtual_network_name = azurerm_virtual_network.tech264_georgia_vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

# App VM NSG (allow ports 22, 80, 3000)
resource "azurerm_network_security_group" "tech264_georgia_app_nsg" {
  name                = "tech264_georgia_app_nsg"
  location            = "UK South"
  resource_group_name = "tech264"

  # Security rule: 22/allow ssh
  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Security rule: 80/allow http
  security_rule {
    name                       = "allow_http"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Security rule: 3000
  security_rule {
    name                       = "allow_3000"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# DB VM NSG (allow SSH and MongoDB, deny all else)
resource "azurerm_network_security_group" "tech264_georgia_db_nsg" {
  name                = "tech264_georgia_db_nsg"
  location            = "UK South"
  resource_group_name = "tech264"

  # Security rule: 22/allow ssh
  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Security rule: 27017/allow Mongo
  security_rule {
    name                       = "allow_mongo"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "27017"
    source_address_prefix      = "10.0.1.0/24" # CIDR of the public subnet
    destination_address_prefix = "*"
  }

  # Security rule: deny everything else (imbound traffic)
  security_rule {
    name                       = "deny_all_inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# create a Public IP Address Resource
resource "azurerm_public_ip" "app_vm_public_ip" {
  name                = "app_vm_public_ip"
  location            = "UK South"
  resource_group_name = "tech264"
  allocation_method   = "Static"
}

# Create Network Interface for App VM
resource "azurerm_network_interface" "tech264_georgia_app_nic" {
  name                = "tech264_georgia_app_nic"
  location            = "UK South"
  resource_group_name = "tech264"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.app_vm_public_ip.id
  }
}

# Create App VM
resource "azurerm_linux_virtual_machine" "app_vm" {
  name                            = "tech264-georgia-tf-app-vm"
  location                        = "UK South"
  resource_group_name             = "tech264"
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  network_interface_ids           = [azurerm_network_interface.tech264_georgia_app_nic.id]
  disable_password_authentication = true

  # Add SSH Key
  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.admin_public_key_path) # Path to your SSH public key
  }

  # Add User Data
  user_data = filebase64(var.user_data_script_path) # Path to your script

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = var.source_image_id
}


# NSG association for App VM
resource "azurerm_network_interface_security_group_association" "nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.tech264_georgia_app_nic.id
  network_security_group_id = azurerm_network_security_group.tech264_georgia_app_nsg.id
}

# Create Network Interface for DB VM
resource "azurerm_network_interface" "tech264_georgia_db_nic" {
  name                = "tech264_georgia_db_nic"
  location            = "UK South"
  resource_group_name = "tech264"
  ip_configuration {
    name                          = "db-ip-config"
    subnet_id                     = azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create DB VM
# Create a DB VM
resource "azurerm_linux_virtual_machine" "db_vm" {
  name                            = "tech264-georgia-tf-db-vm"
  location                        = "UK South"
  resource_group_name             = "tech264"
  size                            = "Standard_B1s"
  admin_username                  = "adminuser"
  network_interface_ids           = [azurerm_network_interface.tech264_georgia_db_nic.id]
  disable_password_authentication = true

  # Add SSH Key
  admin_ssh_key {
    username   = "adminuser"
    public_key = file(var.admin_public_key_path) # Path to your SSH public key
  }

  # Add User Data
  user_data = filebase64(var.database_user_data_script_path) # Path to your script


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_id = var.db_source_image_id
}

# NSG association for DB VM
resource "azurerm_network_interface_security_group_association" "db_nic_nsg_association" {
  network_interface_id      = azurerm_network_interface.tech264_georgia_db_nic.id
  network_security_group_id = azurerm_network_security_group.tech264_georgia_db_nsg.id
}
