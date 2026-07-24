output "resource_group_name" {
  description = "Resource group created for the demo."
  value       = azurerm_resource_group.demo.name
}

output "storage_account_name" {
  description = "Storage account that contains the CSV export."
  value       = azurerm_storage_account.exports.name
}

output "storage_container_name" {
  description = "Blob container that contains the CSV export."
  value       = azurerm_storage_container.exports.name
}

output "csv_blob_name" {
  description = "CSV blob written by the query runner."
  value       = var.csv_blob_name
}

output "container_logs_command" {
  description = "Command to view the one-shot query runner logs."
  value       = "az container logs --resource-group ${azurerm_resource_group.demo.name} --name ${azurerm_container_group.query_runner.name}"
}

output "download_csv_command" {
  description = "Command to download the generated CSV from Blob Storage."
  value       = "az storage blob download --auth-mode login --account-name ${azurerm_storage_account.exports.name} --container-name ${azurerm_storage_container.exports.name} --name ${var.csv_blob_name} --file ${basename(var.csv_blob_name)} --overwrite"
}

output "destroy_command" {
  description = "Script command to destroy the demo resources when you are ready."
  value       = "../scripts/destroy_azure_demo.sh"
}
