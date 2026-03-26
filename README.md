The Terraform module is used by the ITGix AWS Landing Zone - https://itgix.com/itgix-landing-zone/

# AWS Site-to-Site VPN Terraform Module

This module creates an AWS Site-to-Site VPN connection with configurable tunnel parameters, IKE settings, and support for both VPN Gateway and Transit Gateway attachments.

Part of the [ITGix AWS Landing Zone](https://itgix.com/itgix-landing-zone/).

## Resources Created

- VPN connection (with optional static routes)
- VPN Gateway attachment
- Route propagation to VPC route tables
- *(Optional)* Transit Gateway VPN attachment

## Requirements

| Name | Version |
|------|---------|
| Terraform | >= 1.0 |
| AWS provider | >= 4.66 |

## Inputs

> This module has **55 variables** covering detailed tunnel configuration. The key variables are listed below. See `variables.tf` for the complete list including all tunnel phase 1/2 encryption, integrity, DH group, and lifetime settings.

### Connection

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `create_vpn_connection` | Whether to create a VPN Connection | `bool` | `true` | no |
| `customer_gateway_id` | The ID of the Customer Gateway | `string` | — | yes |
| `vpn_gateway_id` | The ID of the VPN Gateway | `string` | `null` | no |
| `transit_gateway_id` | The ID of the Transit Gateway | `string` | `null` | no |
| `vpc_id` | The ID of the VPC | `string` | `null` | no |
| `connect_to_transit_gateway` | Attach VPN to Transit Gateway instead of VPN Gateway | `bool` | `false` | no |
| `create_vpn_gateway_attachment` | Whether to attach VGW to VPC | `bool` | `true` | no |
| `tags` | Tags for the VPN Connection | `map(string)` | `{}` | no |

### Static Routes

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `vpn_connection_static_routes_only` | Use static routes exclusively | `bool` | `false` | no |
| `vpn_connection_static_routes_destinations` | List of destination CIDRs for static routes | `list(string)` | `[]` | no |
| `vpc_subnet_route_table_ids` | VPC subnet route table IDs for route propagation | `list(string)` | `[]` | no |
| `vpc_subnet_route_table_count` | Number of subnet route table IDs | `number` | `0` | no |

### Tunnel Configuration

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `tunnel1_inside_cidr` | Inside CIDR for tunnel 1 | `string` | `""` | no |
| `tunnel2_inside_cidr` | Inside CIDR for tunnel 2 | `string` | `""` | no |
| `tunnel1_preshared_key` | Preshared key for tunnel 1 | `string` | `""` | no |
| `tunnel2_preshared_key` | Preshared key for tunnel 2 | `string` | `""` | no |
| `tunnel_inside_ip_version` | IP version for tunnel inside (ipv4 or ipv6) | `string` | `null` | no |
| `tunnel1_ike_versions` | IKE versions for tunnel 1 | `list(string)` | `null` | no |
| `tunnel2_ike_versions` | IKE versions for tunnel 2 | `list(string)` | `null` | no |
| `tunnel1_startup_action` | Startup action for tunnel 1 | `string` | `null` | no |
| `tunnel2_startup_action` | Startup action for tunnel 2 | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| `vpn_connection_id` | VPN Connection ID |
| `vpn_connection_tunnel1_address` | Public IP of tunnel 1 |
| `vpn_connection_tunnel1_cgw_inside_address` | CGW inside address of tunnel 1 |
| `vpn_connection_tunnel1_vgw_inside_address` | VGW inside address of tunnel 1 |
| `vpn_connection_tunnel2_address` | Public IP of tunnel 2 |
| `vpn_connection_tunnel2_cgw_inside_address` | CGW inside address of tunnel 2 |
| `vpn_connection_tunnel2_vgw_inside_address` | VGW inside address of tunnel 2 |

## Usage Example

```hcl
module "s2s_vpn" {
  source = "path/to/tf-module-aws-s2s-vpn"

  customer_gateway_id = "cgw-0abc1234def567890"
  vpn_gateway_id      = "vgw-0abc1234def567890"
  vpc_id              = "vpc-0abc1234def567890"

  vpn_connection_static_routes_only         = true
  vpn_connection_static_routes_destinations = ["192.168.0.0/16"]

  vpc_subnet_route_table_ids   = ["rtb-aaa111", "rtb-bbb222"]
  vpc_subnet_route_table_count = 2

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```
