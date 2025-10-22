# ##############################################
# ##Routes
# ###############################################

module "iden_routes" {
  source              = "./modules/routes"
  route_table_name    = "rt-iden-eus-dev-001"
  route_names         = ["iden-to-mgmt"]
  instance_number     = var.instance_number
  environment         = var.environment
  resource_group_name = module.resource_group["spoke02"].name
  location            = var.location
  route_prefixes      = ["10.190.194.0/26"] #mgmt subnet
  fw_private_ip       = "10.189.194.4"

}


resource "azurerm_subnet_route_table_association" "iden_assoc" {
  subnet_id      = module.subnets["spoke02"].id
  route_table_id = module.iden_routes.route_table_id
}

module "mgmt_routes" {
  source              = "./modules/routes"
  route_table_name    = "rt-mgmt-eus-dev-001"
  route_names         = ["mgmt-to-iden"]
  instance_number     = var.instance_number
  environment         = var.environment
  resource_group_name = module.resource_group["spoke01"].name
  location            = var.location
  route_prefixes      = ["10.191.194.0/26"] #identity subnet
  fw_private_ip       = "10.189.194.4"

}

resource "azurerm_subnet_route_table_association" "mgmt_assoc" {
  subnet_id      = module.subnets["spoke01"].id
  route_table_id = module.mgmt_routes.route_table_id
}