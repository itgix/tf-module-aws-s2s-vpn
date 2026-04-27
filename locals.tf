locals {
  preshared_key_provided     = length(var.tunnel1_preshared_key) > 0 && length(var.tunnel2_preshared_key) > 0
  preshared_key_not_provided = false == local.preshared_key_provided
  internal_cidr_provided     = length(var.tunnel1_inside_cidr) > 0 && length(var.tunnel2_inside_cidr) > 0
  internal_cidr_not_provided = false == local.internal_cidr_provided

  tunnel_details_not_specified = local.internal_cidr_not_provided && local.preshared_key_not_provided
  tunnel_details_specified     = local.internal_cidr_provided && local.preshared_key_provided

  create_tunnel_with_internal_cidr_only = local.internal_cidr_provided && local.preshared_key_not_provided
  create_tunnel_with_preshared_key_only = local.internal_cidr_not_provided && local.preshared_key_provided

  connection_identifier = var.connect_to_transit_gateway ? "TGW ${var.transit_gateway_id}" : "VPC ${var.vpc_id}"
  name_tag              = "VPN Connection between ${local.connection_identifier} and Customer Gateway ${var.customer_gateway_id}"

  vpn_connection_id = try(
    aws_vpn_connection.default[0].id,
    aws_vpn_connection.tunnel[0].id,
    aws_vpn_connection.preshared[0].id,
    aws_vpn_connection.tunnel_preshared[0].id,
    ""
  )
}
