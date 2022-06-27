# App Service Plan
resource "azurerm_service_plan" "webapp" {
  name                = "${var.prj}-${var.env}-webapp-asp"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Windows"
  sku_name            = "S1"
}

# App Service (Production)
resource "azurerm_windows_web_app" "webapp" {
  name                = "${var.prj}-${var.env}-webapp-as"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_service_plan.webapp.location
  service_plan_id     = azurerm_service_plan.webapp.id

  site_config {
    application_stack {
      current_stack  = "dotnet"
      dotnet_version = "v6.0"
    }
  }
}

# VNet統合(AppService -> VNet)
resource "azurerm_app_service_virtual_network_swift_connection" "webapp" {
  app_service_id = azurerm_windows_web_app.webapp.id
  subnet_id      = azurerm_subnet.data.id
}

# Private Endpoint(VNet -> AppService)
resource "azurerm_private_endpoint" "webapp" {
  name                = "${var.prj}-${var.env}-webapp-as-pep"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.business.id

  private_dns_zone_group {
    name                 = "${var.prj}-${var.env}-webapp-as-dnszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.webapp.id]
  }

  private_service_connection {
    name                           = "${var.prj}-${var.env}-webapp-as-psc"
    private_connection_resource_id = azurerm_windows_web_app.webapp.id
    subresource_names              = ["sites"]
    is_manual_connection           = false
  }
}

# DNS統合
resource "azurerm_private_dns_zone" "webapp" {
  name                = "privatelink.azurewebsites.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "webapp" {
  name                  = "${var.prj}-${var.env}-webapp-as-dnszonelink"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.webapp.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}

# App Service (Production)
resource "azurerm_windows_web_app_slot" "webapp" {
  name           = "staging"
  app_service_id = azurerm_windows_web_app.webapp.id

  site_config {}
}
