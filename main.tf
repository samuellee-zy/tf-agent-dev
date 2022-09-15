provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
	name = "sam-resource-group-test"
	location = "australia east"

}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

resource "azurerm_storage_account" "this" {
  name                     = "testsam"
  resource_group_name      = azurerm_resource_group.this.name
  location                 = azurerm_resource_group.this.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

	# network_rules {
	# 	default_action = "Deny"
	# 	ip_rules = ["20.46.110.61"]
	# }
}

resource "azurerm_storage_account_network_rules" "network_rules" {
    storage_account_id  = azurerm_storage_account.this.id
    default_action        = "Deny"
    bypass         = ["Logging","AzureServices","Metrics"]
    #virtual_network_subnet_ids = [azurerm_subnet.environment.id,azurerm_subnet.private_endpoint.id]
    ip_rules                   = [chomp(data.http.myip.body)]
    depends_on            = [
    azurerm_storage_container.environment,
    azurerm_storage_container.environmentlogs
  ]
}

resource "azurerm_storage_container" "this" {
  name = "assets"
  storage_account_name  = azurerm_storage_account.this.name
  container_access_type = "private"
}

output "ipAddress" {
  value = chomp(data.http.myip.body)
}

/*
# Azure Storage configuration
resource "azurerm_storage_account" "environment" {
  name                  = "sa${var.project_client}${var.project_name}${var.environment_name}"
  resource_group_name   = azurerm_resource_group.environment.name
  location              = var.environment_location
  account_tier          = "Standard"
  account_replication_type = "LRS"

  identity {
    type = "SystemAssigned"
  }
}
resource "azurerm_storage_account_network_rules" "network_rules" {
    storage_account_id  = azurerm_storage_account.environment.id
    default_action        = "Deny"
    bypass         = ["Logging","AzureServices","Metrics"]
    virtual_network_subnet_ids = [azurerm_subnet.environment.id,azurerm_subnet.private_endpoint.id]
    ip_rules                   = [chomp(data.http.myip.body)]
    depends_on            = [
    azurerm_storage_container.environment,
    azurerm_storage_container.environmentlogs
  ]
  }

###########################

# Azure Storage account managed keys

resource "azurerm_storage_account_customer_managed_key" "environment" {
  storage_account_id  = azurerm_storage_account.environment.id
  key_vault_id        = azurerm_key_vault.environment.id
  key_name            = azurerm_key_vault_key.storage_account_customer_managed_key.name
}

resource "azurerm_advanced_threat_protection" "environment" {
  target_resource_id    = azurerm_storage_account.environment.id
  enabled               = true
}

##############################

# Azure storage container
resource "azurerm_storage_container" "environment" {
  name = "assets"
  storage_account_name  = azurerm_storage_account.environment.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "environmentlogs" {
  name = "logs"
  storage_account_name  = azurerm_storage_account.environment.name
  container_access_type = "private"
}
####################################

# Azure Storage account role assignment

resource "azurerm_role_assignment" "storage_contributor_developers" {
  scope                 = azurerm_storage_account.environment.id
  role_definition_name  = "Contributor"
  principal_id          = data.azuread_group.developers.id
}

resource "azurerm_role_assignment" "storage_contributor_appservice_environment" {
  scope                 = azurerm_storage_account.environment.id
  role_definition_name  = "Contributor"
  principal_id          = azurerm_app_service.environment.identity.0.principal_id
}

resource "azurerm_role_assignment" "storage_blobdatacontributor_developers" {
  scope                 = azurerm_storage_account.environment.id
  role_definition_name  = "Storage Blob Data Contributor"
  principal_id          = data.azuread_group.developers.id
}

resource "azurerm_role_assignment" "storage_blobdatacontributor_appservice_environment" {
  scope                 = azurerm_storage_account.environment.id
  role_definition_name  = "Storage Blob Data Contributor"
  principal_id          = azurerm_app_service.environment.identity.0.principal_id
}

#######################################
*/