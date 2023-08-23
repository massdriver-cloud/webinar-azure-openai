locals {
  artifact_data_etc = {
    api_key = azurerm_cognitive_account.main.primary_access_key
  }

  public_artifact_data = {
    etc = local.artifact_data_etc
    api = {
      hostname = azurerm_cognitive_account.main.endpoint
      port     = 443
    }
  }

  artifact_specs = {
    api = {
      version = "0.0.1"
    }
  }
}

resource "massdriver_artifact" "endpoint" {
  field                = "endpoint"
  provider_resource_id = "${var.md_metadata.name_prefix}-api-endpoint"
  name                 = "Public API endpoint for ${var.md_metadata.name_prefix}"
  artifact = jsonencode({
    data  = local.public_artifact_data
    specs = local.artifact_specs
  })
}
