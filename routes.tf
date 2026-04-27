resource "aws_vpn_connection_route" "default" {
  count = var.create_vpn_connection && var.vpn_connection_static_routes_only && !var.connect_to_transit_gateway ? length(var.vpn_connection_static_routes_destinations) : 0

  vpn_connection_id      = local.vpn_connection_id
  destination_cidr_block = element(var.vpn_connection_static_routes_destinations, count.index)
}
