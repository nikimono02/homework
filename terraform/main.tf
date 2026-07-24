data "azurerm_client_config" "current" {}

locals {
  raw_resource_group_name = coalesce(var.resource_group_name, "${var.name_prefix}-rg")
  clean_name_prefix       = replace(lower(var.name_prefix), "/[^a-z0-9]/", "")
  storage_name_prefix     = length(local.clean_name_prefix) > 0 ? substr(local.clean_name_prefix, 0, 11) : "tfquerydemo"
  storage_account_name    = substr("${local.storage_name_prefix}${random_string.storage_suffix.result}", 0, 24)

  default_resource_graph_query = <<-KQL
    Resources
    | where resourceGroup =~ '${local.raw_resource_group_name}'
    | project name, type, location, resourceGroup, subscriptionId
    | order by type asc, name asc
  KQL

  resource_graph_query = coalesce(var.resource_graph_query, local.default_resource_graph_query)

  common_tags = merge(var.tags, {
    managed_by = "terraform"
    purpose    = "query-csv-export-demo"
  })

  query_runner_command = templatefile("${path.module}/scripts/query_runner.sh.tftpl", {
    blob_name                  = var.csv_blob_name
    container_name             = azurerm_storage_container.exports.name
    csv_file_name              = basename(var.csv_blob_name)
    managed_identity_client_id = azurerm_user_assigned_identity.query_runner.client_id
    query                      = local.resource_graph_query
    rbac_initial_delay_seconds = var.rbac_initial_delay_seconds
    storage_account_name       = azurerm_storage_account.exports.name
    subscription_id            = data.azurerm_client_config.current.subscription_id
  })
}

resource "random_string" "storage_suffix" {
  length  = 8
  lower   = true
  numeric = true
  special = false
  upper   = false
}

resource "azurerm_resource_group" "demo" {
  name     = local.raw_resource_group_name
  location = var.location
  tags     = local.common_tags
}

resource "azurerm_storage_account" "exports" {
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.demo.name
  location                        = azurerm_resource_group.demo.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  min_tls_version                 = "TLS1_2"
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "exports" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.exports.name
  container_access_type = "private"
}

resource "azurerm_user_assigned_identity" "query_runner" {
  name                = "${var.name_prefix}-query-runner-mi"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  tags                = local.common_tags
}

resource "azurerm_role_assignment" "query_runner_reader" {
  scope                = azurerm_resource_group.demo.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.query_runner.principal_id

  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "query_runner_blob_contributor" {
  scope                = azurerm_storage_account.exports.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_user_assigned_identity.query_runner.principal_id

  skip_service_principal_aad_check = true
}

resource "azurerm_role_assignment" "current_principal_blob_reader" {
  scope                = azurerm_storage_account.exports.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_container_group" "query_runner" {
  name                = "${var.name_prefix}-query-runner"
  resource_group_name = azurerm_resource_group.demo.name
  location            = azurerm_resource_group.demo.location
  os_type             = "Linux"
  restart_policy      = "Never"
  ip_address_type     = "None"
  tags                = local.common_tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.query_runner.id]
  }

  container {
    name   = "query-runner"
    image  = var.container_image
    cpu    = var.container_cpu
    memory = var.container_memory_gb

    commands = [
      "/bin/sh",
      "-c",
      local.query_runner_command,
    ]
  }

  depends_on = [
    azurerm_role_assignment.current_principal_blob_reader,
    azurerm_role_assignment.query_runner_blob_contributor,
    azurerm_role_assignment.query_runner_reader,
  ]
}
