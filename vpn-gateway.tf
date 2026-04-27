resource "aws_vpn_gateway_attachment" "default" {
  count = var.create_vpn_connection && var.create_vpn_gateway_attachment && !var.connect_to_transit_gateway ? 1 : 0

  vpc_id         = var.vpc_id
  vpn_gateway_id = var.vpn_gateway_id
}

resource "aws_vpn_gateway_route_propagation" "private_subnets_vpn_routing" {
  count = var.create_vpn_connection && !var.connect_to_transit_gateway ? length(var.vpc_subnet_route_table_ids) : 0

  vpn_gateway_id = var.vpn_gateway_id
  route_table_id = element(var.vpc_subnet_route_table_ids, count.index)
}
