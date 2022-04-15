# Create network interface
resource "azurerm_network_interface" "myterraformnic" {
    name                      = "${var.vmname}-mynic-${random_id.randomIdVM.hex}"
    location                  = var.location
    resource_group_name       = var.rgname

    ip_configuration {
        name                          = "mynicconfiguration"
        subnet_id                     = var.subnetid
        private_ip_address_allocation = "Dynamic"
    }

    tags = {
        environment = ""
    }
}
# Generate random text for a unique storage account name and DNS label
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = var.rgname
    }
    byte_length = 8
}
resource "random_id" "randomIdVM" {
    
        byte_length = 8
}


# Create storage account for boot diagnostics
resource "azurerm_storage_account" "mystorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = var.rgname
    location                    = var.location
    account_tier                = "Standard"
    account_replication_type    = "LRS"
}

# Create virtual machine
resource "azurerm_virtual_machine" "myterraformvm" {
    name                             = var.vmname
    location                         = var.location
    resource_group_name              = var.rgname
    network_interface_ids            = [azurerm_network_interface.myterraformnic.id]
    vm_size                          = var.vmsize
    delete_os_disk_on_termination    = true
    delete_data_disks_on_termination = true

    storage_os_disk {
        name              = "${var.vmname}-myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    source_image_reference   { 
     publisher   =   "MicrosoftWindowsServer" 
     offer       =   "WindowsServer" 
     sku         =   "2019-Datacenter" 
     version     =   "latest" 
   } 

    os_profile {
        computer_name  = var.vmname
        admin_username = var.adminusername
        admin_password = var.vmpassword
    }
#for linux
    # os_profile_linux_config {
    #     disable_password_authentication = false
    # }

    boot_diagnostics {
        enabled = "true"
        storage_uri = azurerm_storage_account.mystorageaccount.primary_blob_endpoint
    }
        tags = {
        environment = ""
    }

}