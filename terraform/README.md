# Azure Terraform Query-to-CSV Demo

This Terraform example creates a small Azure environment that runs an Azure
Resource Graph query and writes the result to a CSV file in Blob Storage.

## What Gets Created

- Resource group
- Storage account
- Private blob container for CSV exports
- User-assigned managed identity
- RBAC assignments for Resource Graph read access and Blob upload access
- One-shot Azure Container Instance that runs the query and uploads the CSV

## Prerequisites

- Terraform 1.5 or newer
- Azure CLI
- An Azure account with permission to create resources and role assignments

Log in and select the subscription you want to use:

```sh
az login
az account set --subscription "<subscription-id-or-name>"
```

Make sure the required Azure resource providers are registered:

```sh
az provider register --namespace Microsoft.ContainerInstance
az provider register --namespace Microsoft.ManagedIdentity
az provider register --namespace Microsoft.ResourceGraph
az provider register --namespace Microsoft.Storage
```

## Create The Demo

From the repository root:

```sh
./scripts/apply_azure_demo.sh
```

Terraform provisions the services, waits briefly for RBAC propagation, and then
starts the query runner container. The default query inventories resources in
the demo resource group:

```kusto
Resources
| where resourceGroup =~ '<demo-resource-group>'
| project name, type, location, resourceGroup, subscriptionId
| order by type asc, name asc
```

## Check The CSV

The CSV is uploaded to the storage account as:

```text
exports/resource-inventory.csv
```

Download it locally:

```sh
./scripts/download_azure_demo_csv.sh
```

Or copy the exact download command from Terraform:

```sh
terraform -chdir=terraform output -raw download_csv_command
```

To inspect the query runner logs:

```sh
terraform -chdir=terraform output -raw container_logs_command
```

## Customize

Copy the example variables file before editing:

```sh
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Common values to change:

- `location`
- `name_prefix`
- `resource_graph_query`
- `csv_blob_name`

## Destroy Later

Do not run this until you are ready to remove the demo resources:

```sh
./scripts/destroy_azure_demo.sh
```
