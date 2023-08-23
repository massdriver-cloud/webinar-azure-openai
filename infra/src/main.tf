resource "azurerm_resource_group" "main" {
  name     = var.md_metadata.name_prefix
  location = var.region
}

resource "azurerm_cognitive_account" "main" {
  name                  = var.md_metadata.name_prefix
  location              = var.region
  resource_group_name   = azurerm_resource_group.main.name
  custom_subdomain_name = var.md_metadata.name_prefix
  kind                  = "OpenAI"
  sku_name              = "S0"
}
