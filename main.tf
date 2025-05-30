module "log_analytics_workspace" {
  source  = "app.terraform.io/anishgehlot/log_analytics_workspace/azure"
  version = "1.0.0"

  workspace_name      = "laws"
  resource_group_name = "testrg"
  workspace_retention = 30
  sku                 = "PerGB2018"
  tags                = {
    evn = "dev"
  }

}
