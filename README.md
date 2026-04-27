The Terraform module is used by the ITGix AWS Landing Zone - https://itgix.com/itgix-landing-zone/

# AWS Site-to-Site VPN Terraform Module

This module creates an AWS Site-to-Site VPN connection with configurable tunnel parameters, IKE settings, and support for both VPN Gateway and Transit Gateway attachments.

Part of the [ITGix AWS Landing Zone](https://itgix.com/itgix-landing-zone/).

## Resources Created

- VPN connection (with optional static routes)
- *(VGW mode)* VPN Gateway attachment and route propagation to VPC route tables
- *(TGW mode)* Transit Gateway VPN attachment

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

## Attachment Modes

This module supports two mutually exclusive approaches for attaching the VPN connection:

### Approach 1 — Transit Gateway (TGW) Mode

Centralized routing — VPN traffic flows through a Transit Gateway hub to reach multiple VPCs and accounts.

```
External Network → Customer Gateway → VPN → Transit Gateway → Application VPCs (and vice-versa)
```

Set:
```hcl
connect_to_transit_gateway    = true
create_vpn_gateway_attachment = false
transit_gateway_id            = "<tgw-id>"
```

### Approach 2 — Virtual Private Gateway (VGW) Mode

Direct attachment — VPN connects to a single VPC via a Virtual Private Gateway.

```
External Network → Customer Gateway → VPN → VGW → Single VPC (and vice-versa)
```

Set:
```hcl
connect_to_transit_gateway    = false   # default
create_vpn_gateway_attachment = true    # default
vpn_gateway_id                = "<vgw-id>"
vpc_subnet_route_table_ids    = ["rtb-xxx", ...]
vpc_subnet_route_table_count  = <number>
```

## Usage Examples

### TGW Mode

```hcl
# Customer Gateway — represents the remote (on-prem) VPN device
resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = "203.0.113.1" # Public IP of the on-prem VPN device
  type       = "ipsec.1"

  tags = {
    Name = "customer-gateway"
  }
}

# S2S VPN module — attached to Transit Gateway
module "s2s_vpn" {
  source = "path/to/tf-module-aws-s2s-vpn"

  customer_gateway_id = aws_customer_gateway.main.id
  transit_gateway_id  = module.transit_gateway.ec2_transit_gateway_id
  vpc_id              = module.egress_vpc.vpc_id

  connect_to_transit_gateway    = true
  create_vpn_gateway_attachment = false

  vpn_connection_static_routes_only         = true
  vpn_connection_static_routes_destinations = ["10.100.0.0/24"]
  local_ipv4_network_cidr                   = "10.100.0.0/24"
  remote_ipv4_network_cidr                  = "10.0.0.0/11"

  tunnel_inside_ip_version = "ipv4"

  # Tunnel 1
  tunnel1_inside_cidr                  = "169.254.100.0/30"
  tunnel1_dpd_timeout_action           = "restart"
  tunnel1_dpd_timeout_seconds          = 120
  tunnel1_ike_versions                 = ["ikev2"]
  tunnel1_phase1_dh_group_numbers      = [15]
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms  = ["SHA2-512"]
  tunnel1_phase2_dh_group_numbers      = [15]
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase2_integrity_algorithms  = ["SHA2-512"]
  tunnel1_startup_action               = "start"
  tunnel1_preshared_key                = var.tunnel1_preshared_key
  tunnel1_rekey_margin_time_seconds    = 270

  # Tunnel 2
  tunnel2_inside_cidr                  = "169.254.200.0/30"
  tunnel2_dpd_timeout_action           = "restart"
  tunnel2_ike_versions                 = ["ikev2"]
  tunnel2_phase1_dh_group_numbers      = [15]
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase1_integrity_algorithms  = ["SHA2-512"]
  tunnel2_phase2_dh_group_numbers      = [15]
  tunnel2_phase2_encryption_algorithms = ["AES256"]
  tunnel2_phase2_integrity_algorithms  = ["SHA2-512"]
  tunnel2_startup_action               = "start"
  tunnel2_preshared_key                = var.tunnel2_preshared_key
  tunnel2_rekey_margin_time_seconds    = 270

  tags = {
    Name      = "VPN connection TGW to CGW"
    ManagedBy = "Terraform"
  }
}

# Associate the VPN TGW attachment with a TGW route table
resource "aws_ec2_transit_gateway_route_table_association" "vpn" {
  transit_gateway_attachment_id  = module.s2s_vpn.vpn_connection_transit_gateway_attachment_id
  transit_gateway_route_table_id = module.transit_gateway.tgw_common_route_table_id
}

# Static route on the TGW route table: on-prem CIDR → VPN attachment
resource "aws_ec2_transit_gateway_route" "onprem_via_vpn" {
  destination_cidr_block         = "10.100.0.0/24"
  transit_gateway_attachment_id  = module.s2s_vpn.vpn_connection_transit_gateway_attachment_id
  transit_gateway_route_table_id = module.transit_gateway.tgw_inspection_route_table_id
}
```

### VGW Mode

```hcl
# Customer Gateway — represents the remote (on-prem) VPN device
resource "aws_customer_gateway" "main" {
  bgp_asn    = 65000
  ip_address = "203.0.113.1" # Public IP of the on-prem VPN device
  type       = "ipsec.1"

  tags = {
    Name = "customer-gateway"
  }
}

# S2S VPN module — attached directly to a VPC via Virtual Private Gateway
module "s2s_vpn" {
  source = "path/to/tf-module-aws-s2s-vpn"

  customer_gateway_id = aws_customer_gateway.main.id
  vpn_gateway_id      = aws_vpn_gateway.main.id
  vpc_id              = module.vpc.vpc_id

  connect_to_transit_gateway    = false
  create_vpn_gateway_attachment = true

  vpn_connection_static_routes_only         = true
  vpn_connection_static_routes_destinations = ["192.168.0.0/16"]

  vpc_subnet_route_table_ids   = module.vpc.private_route_table_ids
  vpc_subnet_route_table_count = length(module.vpc.private_route_table_ids)

  tunnel_inside_ip_version = "ipv4"

  # Tunnel 1
  tunnel1_inside_cidr                  = "169.254.100.0/30"
  tunnel1_dpd_timeout_action           = "restart"
  tunnel1_dpd_timeout_seconds          = 120
  tunnel1_ike_versions                 = ["ikev2"]
  tunnel1_phase1_dh_group_numbers      = [15]
  tunnel1_phase1_encryption_algorithms = ["AES256"]
  tunnel1_phase1_integrity_algorithms  = ["SHA2-512"]
  tunnel1_phase2_dh_group_numbers      = [15]
  tunnel1_phase2_encryption_algorithms = ["AES256"]
  tunnel1_phase2_integrity_algorithms  = ["SHA2-512"]
  tunnel1_startup_action               = "start"
  tunnel1_preshared_key                = var.tunnel1_preshared_key
  tunnel1_rekey_margin_time_seconds    = 270

  # Tunnel 2
  tunnel2_inside_cidr                  = "169.254.200.0/30"
  tunnel2_dpd_timeout_action           = "restart"
  tunnel2_ike_versions                 = ["ikev2"]
  tunnel2_phase1_dh_group_numbers      = [15]
  tunnel2_phase1_encryption_algorithms = ["AES256"]
  tunnel2_phase1_integrity_algorithms  = ["SHA2-512"]
  tunnel2_phase2_dh_group_numbers      = [15]
  tunnel2_phase2_encryption_algorithms = ["AES256"]
  tunnel2_phase2_integrity_algorithms  = ["SHA2-512"]
  tunnel2_startup_action               = "start"
  tunnel2_preshared_key                = var.tunnel2_preshared_key
  tunnel2_rekey_margin_time_seconds    = 270

  tags = {
    Name        = "VPN connection VGW to CGW"
    Environment = "production"
    ManagedBy   = "Terraform"
  }
}
```
