locals {
  gateway_ip_configuration_name  = "${var.prj}-${var.env}-appgw-gwip"
  frontend_port_name             = "${var.prj}-${var.env}-appgw-feport"
  frontend_ip_configuration_name = "${var.prj}-${var.env}-appgw-feip"
  backend_address_pool_name      = "${var.prj}-${var.env}-appgw-beap"
  backend_http_setting_name      = "${var.prj}-${var.env}-appgw-behtst"
  probe_name                     = "appsvc-https-probe"
  listener_name                  = "${var.prj}-${var.env}-appgw-httplstn"
  request_routing_rule_name      = "${var.prj}-${var.env}-appgw-rqrt"
  redirect_configuration_name    = "${var.prj}-${var.env}-appgw-rdrcfg"
}

resource "azurerm_application_gateway" "fe" {
  name                = "${var.prj}-${var.env}-fe-appgw"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = local.gateway_ip_configuration_name
    subnet_id = azurerm_subnet.gateway.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                          = local.frontend_ip_configuration_name
    public_ip_address_id          = azurerm_public_ip.appgw.id
    private_ip_address_allocation = "Dynamic"
  }

  backend_address_pool {
    name  = local.backend_address_pool_name
    fqdns = [azurerm_windows_web_app.webapp.default_hostname]
  }

  backend_http_settings {
    name                                = local.backend_http_setting_name
    cookie_based_affinity               = "Disabled"
    port                                = 443
    protocol                            = "Https"
    request_timeout                     = 60
    pick_host_name_from_backend_address = true
    probe_name                          = local.probe_name
  }

  probe {
    name                                      = local.probe_name
    protocol                                  = "Https"
    pick_host_name_from_backend_http_settings = true
    path                                      = "/"
    interval                                  = 30
    timeout                                   = 30
    unhealthy_threshold                       = 3
    match {
      status_code = ["200-399"]
      body        = ""
    }
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.backend_http_setting_name
    # priority                   = 10
  }
}

resource "azurerm_public_ip" "appgw" {
  name                = "${var.prj}-${var.env}-appgw-ip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.prj}-${var.env}-appgw"
}
