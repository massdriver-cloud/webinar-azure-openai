locals {
  automated_alarms = {
    errors_metric_alert = {
      severity    = "1"
      frequency   = "PT1M"
      window_size = "PT5M"
      operator    = "GreaterThanOrEqual"
      aggregation = "Average"
      threshold   = 1
    }
  }
  alarms_map = {
    "AUTOMATED" = local.automated_alarms
    "DISABLED"  = {}
    "CUSTOM"    = lookup(var.monitoring, "alarms", {})
  }
  alarms             = lookup(local.alarms_map, var.monitoring.mode, {})
  monitoring_enabled = var.monitoring.mode != "DISABLED" ? 1 : 0
}

module "alarm_channel" {
  source              = "github.com/massdriver-cloud/terraform-modules//azure/alarm-channel?ref=343d3e4"
  md_metadata         = var.md_metadata
  resource_group_name = azurerm_resource_group.main.name
}

module "errors_metric_alert" {
  count                   = local.monitoring_enabled
  source                  = "github.com/massdriver-cloud/terraform-modules//azure/monitor-metrics-alarm?ref=343d3e4"
  scopes                  = [azurerm_cognitive_account.main.id]
  resource_group_name     = azurerm_resource_group.main.name
  monitor_action_group_id = module.alarm_channel.id
  severity                = local.alarms.errors_metric_alert.severity
  frequency               = local.alarms.errors_metric_alert.frequency
  window_size             = local.alarms.errors_metric_alert.window_size

  depends_on = [
    azurerm_cognitive_account.main
  ]

  md_metadata  = var.md_metadata
  display_name = "Server Errors"
  message      = "Active Server Errors"

  alarm_name       = "${var.md_metadata.name_prefix}-activeServerErrors"
  operator         = local.alarms.errors_metric_alert.operator
  metric_name      = "ServerErrors"
  metric_namespace = "microsoft.cognitiveservices/accounts"
  aggregation      = local.alarms.errors_metric_alert.aggregation
  threshold        = local.alarms.errors_metric_alert.threshold
}