variable "subscription_id" {
  description = "Azure subscription ID. The helper scripts populate this from the active Azure CLI account when it is not set."
  type        = string
  default     = null
}

variable "location" {
  description = "Azure region for the demo resources."
  type        = string
  default     = "eastus"
}

variable "name_prefix" {
  description = "Prefix used for Azure resource names. Keep it short because storage account names are globally unique and length-limited."
  type        = string
  default     = "tfquerydemo"
}

variable "resource_group_name" {
  description = "Optional resource group name. Defaults to '<name_prefix>-rg'."
  type        = string
  default     = null
}

variable "storage_container_name" {
  description = "Blob container that receives the CSV export."
  type        = string
  default     = "exports"
}

variable "csv_blob_name" {
  description = "Blob name for the exported CSV file."
  type        = string
  default     = "resource-inventory.csv"
}

variable "resource_graph_query" {
  description = "Optional Azure Resource Graph KQL query. Defaults to an inventory query for this demo resource group."
  type        = string
  default     = null
}

variable "container_image" {
  description = "Container image used by the one-shot query runner."
  type        = string
  default     = "mcr.microsoft.com/azure-cli:latest"
}

variable "container_cpu" {
  description = "CPU cores for the one-shot query runner container."
  type        = number
  default     = 0.5
}

variable "container_memory_gb" {
  description = "Memory in GB for the one-shot query runner container."
  type        = number
  default     = 1
}

variable "rbac_initial_delay_seconds" {
  description = "How long the query runner waits before its first Azure API call, allowing RBAC assignments time to propagate."
  type        = number
  default     = 45
}

variable "tags" {
  description = "Tags applied to Azure resources."
  type        = map(string)
  default = {
    project = "terraform-query-csv-demo"
  }
}
