### Fix tagging on Transit Gateway Attachment if it exists
resource "aws_ec2_tag" "tags" {
  for_each = { for key, value in merge({ "Name" = local.name_tag }, var.tags) : key => value if var.create_vpn_connection && var.connect_to_transit_gateway }

  resource_id = try(
    aws_vpn_connection.default[0].transit_gateway_attachment_id,
    aws_vpn_connection.tunnel[0].transit_gateway_attachment_id,
    aws_vpn_connection.preshared[0].transit_gateway_attachment_id,
    aws_vpn_connection.tunnel_preshared[0].transit_gateway_attachment_id
  )

  key   = each.key
  value = each.value
}
