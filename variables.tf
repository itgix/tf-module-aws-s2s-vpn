variable "vpn_gateway_id" {
  description = "The id of the VPN Gateway."
  type        = string
  default     = null
}

variable "transit_gateway_id" {
  description = "The ID of the Transit Gateway."
  type        = string
  default     = null
}

variable "customer_gateway_id" {
  description = "The id of the Customer Gateway."
  type        = string
}

variable "create_vpn_connection" {
  description = "Set to false to prevent the creation of a VPN Connection."
  type        = bool
  default     = true
}

variable "vpc_id" {
  description = "The id of the VPC where the VPN Gateway lives."
  type        = string
  default     = null
}

variable "vpc_subnet_route_table_ids" {
  description = "The ids of the VPC subnets for which routes from the VPN Gateway will be propagated."
  type        = list(string)
  default     = []
}

# Deprecated: no longer needed since Terraform >= 1.0 supports length() on computed values in count.
# Kept for backward compatibility; this variable is ignored.
variable "vpc_subnet_route_table_count" {
  description = "Deprecated — the module now uses length(vpc_subnet_route_table_ids) automatically. This variable is ignored."
  type        = number
  default     = 0
}

variable "tags" {
  description = "Set of tags to be added to the VPN Connection resource (only if `create_vpn_connection = true`)."
  type        = map(string)
  default     = {}
}

variable "vpn_connection_static_routes_only" {
  description = "Set to true for the created VPN connection to use static routes exclusively (only if `create_vpn_connection = true`). Static routes must be used for devices that don't support BGP."
  type        = bool
  default     = false
}

variable "vpn_connection_static_routes_destinations" {
  description = "List of CIDRs to be used as destination for static routes (used with `vpn_connection_static_routes_only = true`). Routes to destinations set here will be propagated to the routing tables of the subnets defined in `vpc_subnet_route_table_ids`."
  type        = list(string)
  default     = []
}

variable "tunnel1_inside_cidr" {
  description = "The CIDR block of the inside IP addresses for the first VPN tunnel."
  type        = string
  default     = ""

  validation {
    condition     = var.tunnel1_inside_cidr == "" || can(cidrhost(var.tunnel1_inside_cidr, 0))
    error_message = "Must be a valid CIDR block (e.g. 169.254.100.0/30)."
  }
}

variable "tunnel2_inside_cidr" {
  description = "The CIDR block of the inside IP addresses for the second VPN tunnel."
  type        = string
  default     = ""

  validation {
    condition     = var.tunnel2_inside_cidr == "" || can(cidrhost(var.tunnel2_inside_cidr, 0))
    error_message = "Must be a valid CIDR block (e.g. 169.254.200.0/30)."
  }
}

variable "tunnel1_preshared_key" {
  description = "The preshared key of the first VPN tunnel."
  type        = string
  default     = ""
  sensitive   = true
}

variable "tunnel2_preshared_key" {
  description = "The preshared key of the second VPN tunnel."
  type        = string
  default     = ""
  sensitive   = true
}

# Attachment can be already managed by the terraform-aws-vpc module by using the enable_vpn_gateway variable
variable "create_vpn_gateway_attachment" {
  description = "Set to false to prevent attachment of the VGW to the VPC."
  type        = bool
  default     = true
}

# Use terraform-aws-transit-gateway module to create TGW required resources and set `connect_to_transit_gateway = true` here
variable "connect_to_transit_gateway" {
  description = "Set to false to disable attachment of the VPN connection route to the VPN connection (TGW uses another resource for that)."
  type        = bool
  default     = false
}

variable "tunnel1_phase1_dh_group_numbers" {
  description = "(Optional) List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are 2 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24."
  type        = list(number)
  default     = null

  validation {
    condition     = var.tunnel1_phase1_dh_group_numbers == null || alltrue([for n in var.tunnel1_phase1_dh_group_numbers : contains([2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], n)])
    error_message = "Valid values are: 2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24."
  }
}

variable "tunnel2_phase1_dh_group_numbers" {
  description = "(Optional) List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are 2 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24."
  type        = list(number)
  default     = null

  validation {
    condition     = var.tunnel2_phase1_dh_group_numbers == null || alltrue([for n in var.tunnel2_phase1_dh_group_numbers : contains([2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], n)])
    error_message = "Valid values are: 2, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24."
  }
}

variable "tunnel1_phase1_encryption_algorithms" {
  description = "(Optional) List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16."
  type        = list(string)
  default     = null

  validation {
    condition     = var.tunnel1_phase1_encryption_algorithms == null || alltrue([for a in var.tunnel1_phase1_encryption_algorithms : contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], a)])
    error_message = "Valid values are: AES128, AES256, AES128-GCM-16, AES256-GCM-16."
  }
}

variable "tunnel2_phase1_encryption_algorithms" {
  description = "(Optional) List of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16."
  type        = list(string)
  default     = null

  validation {
    condition     = var.tunnel2_phase1_encryption_algorithms == null || alltrue([for a in var.tunnel2_phase1_encryption_algorithms : contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], a)])
    error_message = "Valid values are: AES128, AES256, AES128-GCM-16, AES256-GCM-16."
  }
}

variable "tunnel1_phase1_integrity_algorithms" {
  description = "(Optional) One or more integrity algorithms that are permitted for the first VPN tunnel for phase 1 IKE negotiations. Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512."
  type        = list(string)
  default     = null

  validation {
    condition     = var.tunnel1_phase1_integrity_algorithms == null || alltrue([for a in var.tunnel1_phase1_integrity_algorithms : contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], a)])
    error_message = "Valid values are: SHA1, SHA2-256, SHA2-384, SHA2-512."
  }
}

variable "tunnel2_phase1_integrity_algorithms" {
  description = "(Optional) One or more integrity algorithms that are permitted for the second VPN tunnel for phase 1 IKE negotiations. Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512."
  type        = list(string)
  default     = null

  validation {
    condition     = var.tunnel2_phase1_integrity_algorithms == null || alltrue([for a in var.tunnel2_phase1_integrity_algorithms : contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], a)])
    error_message = "Valid values are: SHA1, SHA2-256, SHA2-384, SHA2-512."
  }
}

variable "tunnel1_phase1_lifetime_seconds" {
  description = "(Optional, Default 28800) The lifetime for phase 1 of the IKE negotiation for the first VPN tunnel, in seconds. Valid value is between 900 and 28800."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel1_phase1_lifetime_seconds == null || (var.tunnel1_phase1_lifetime_seconds >= 900 && var.tunnel1_phase1_lifetime_seconds <= 28800)
    error_message = "Must be between 900 and 28800."
  }
}

variable "tunnel2_phase1_lifetime_seconds" {
  description = "(Optional, Default 28800) The lifetime for phase 1 of the IKE negotiation for the second VPN tunnel, in seconds. Valid value is between 900 and 28800."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel2_phase1_lifetime_seconds == null || (var.tunnel2_phase1_lifetime_seconds >= 900 && var.tunnel2_phase1_lifetime_seconds <= 28800)
    error_message = "Must be between 900 and 28800."
  }
}

variable "tunnel1_dpd_timeout_seconds" {
  description = "(Optional, Default 30) The number of seconds after which a DPD timeout occurs for the first VPN tunnel. Valid value is equal or higher than 30."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel1_dpd_timeout_seconds == null || var.tunnel1_dpd_timeout_seconds >= 30
    error_message = "Must be >= 30."
  }
}

variable "tunnel2_dpd_timeout_seconds" {
  description = "(Optional, Default 30) The number of seconds after which a DPD timeout occurs for the second VPN tunnel. Valid value is equal or higher than 30."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel2_dpd_timeout_seconds == null || var.tunnel2_dpd_timeout_seconds >= 30
    error_message = "Must be >= 30."
  }
}

variable "tunnel1_dpd_timeout_action" {
  description = "(Optional, Default clear) The action to take after DPD timeout occurs for the first VPN tunnel. Valid values are clear | none | restart."
  type        = string
  default     = null

  validation {
    condition     = var.tunnel1_dpd_timeout_action == null || contains(["clear", "none", "restart"], var.tunnel1_dpd_timeout_action)
    error_message = "Valid values are: clear, none, restart."
  }
}

variable "tunnel2_dpd_timeout_action" {
  description = "(Optional, Default clear) The action to take after DPD timeout occurs for the second VPN tunnel. Valid values are clear | none | restart."
  type        = string
  default     = null

  validation {
    condition     = var.tunnel2_dpd_timeout_action == null || contains(["clear", "none", "restart"], var.tunnel2_dpd_timeout_action)
    error_message = "Valid values are: clear, none, restart."
  }
}

variable "tunnel1_phase2_dh_group_numbers" {
  description = "(Optional) List of one or more Diffie-Hellman group numbers that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24."
  type        = list(number)
  default     = null

  validation {
    condition     = var.tunnel1_phase2_dh_group_numbers == null || alltrue([for n in var.tunnel1_phase2_dh_group_numbers : contains([2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], n)])
    error_message = "Valid values are: 2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24."
  }
}

variable "tunnel2_phase2_dh_group_numbers" {
  description = "(Optional) List of one or more Diffie-Hellman group numbers that are permitted for the second VPN tunnel for phase 2 IKE negotiations. Valid values are 2 | 5 | 14 | 15 | 16 | 17 | 18 | 19 | 20 | 21 | 22 | 23 | 24."
  type        = list(number)
  default     = null

  validation {
    condition     = var.tunnel2_phase2_dh_group_numbers == null || alltrue([for n in var.tunnel2_phase2_dh_group_numbers : contains([2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24], n)])
    error_message = "Valid values are: 2, 5, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24."
  }
}

variable "tunnel1_phase2_encryption_algorithms" {
  description = "(Optional) List of one or more encryption algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16."
  type        = list(string)
  default     = null

  validation {
    condition     = var.tunnel1_phase2_encryption_algorithms == null || alltrue([for a in var.tunnel1_phase2_encryption_algorithms : contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], a)])
    error_message = "Valid values are: AES128, AES256, AES128-GCM-16, AES256-GCM-16."
  }
}

variable "tunnel2_phase2_encryption_algorithms" {
  description = "(Optional) List of one or more encryption algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations. Valid values are AES128 | AES256 | AES128-GCM-16 | AES256-GCM-16."
  type        = list(string)
  default     = null

  validation {
    condition     = var.tunnel2_phase2_encryption_algorithms == null || alltrue([for a in var.tunnel2_phase2_encryption_algorithms : contains(["AES128", "AES256", "AES128-GCM-16", "AES256-GCM-16"], a)])
    error_message = "Valid values are: AES128, AES256, AES128-GCM-16, AES256-GCM-16."
  }
}

variable "tunnel1_phase2_integrity_algorithms" {
  description = "(Optional) List of one or more integrity algorithms that are permitted for the first VPN tunnel for phase 2 IKE negotiations. Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512."
  type        = list(string)
  default     = null

  validation {
    condition     = var.tunnel1_phase2_integrity_algorithms == null || alltrue([for a in var.tunnel1_phase2_integrity_algorithms : contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], a)])
    error_message = "Valid values are: SHA1, SHA2-256, SHA2-384, SHA2-512."
  }
}

variable "tunnel2_phase2_integrity_algorithms" {
  description = "(Optional) List of one or more integrity algorithms that are permitted for the second VPN tunnel for phase 2 IKE negotiations. Valid values are SHA1 | SHA2-256 | SHA2-384 | SHA2-512."
  type        = list(string)
  default     = null

  validation {
    condition     = var.tunnel2_phase2_integrity_algorithms == null || alltrue([for a in var.tunnel2_phase2_integrity_algorithms : contains(["SHA1", "SHA2-256", "SHA2-384", "SHA2-512"], a)])
    error_message = "Valid values are: SHA1, SHA2-256, SHA2-384, SHA2-512."
  }
}

variable "tunnel1_phase2_lifetime_seconds" {
  description = "(Optional, Default 3600) The lifetime for phase 2 of the IKE negotiation for the first VPN tunnel, in seconds. Valid value is between 900 and 3600."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel1_phase2_lifetime_seconds == null || (var.tunnel1_phase2_lifetime_seconds >= 900 && var.tunnel1_phase2_lifetime_seconds <= 3600)
    error_message = "Must be between 900 and 3600."
  }
}

variable "tunnel2_phase2_lifetime_seconds" {
  description = "(Optional, Default 3600) The lifetime for phase 2 of the IKE negotiation for the second VPN tunnel, in seconds. Valid value is between 900 and 3600."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel2_phase2_lifetime_seconds == null || (var.tunnel2_phase2_lifetime_seconds >= 900 && var.tunnel2_phase2_lifetime_seconds <= 3600)
    error_message = "Must be between 900 and 3600."
  }
}

variable "tunnel1_rekey_fuzz_percentage" {
  description = "(Optional, Default 100) The percentage of the rekey window for the first VPN tunnel during which the rekey time is randomly selected. Valid value is between 0 and 100."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel1_rekey_fuzz_percentage == null || (var.tunnel1_rekey_fuzz_percentage >= 0 && var.tunnel1_rekey_fuzz_percentage <= 100)
    error_message = "Must be between 0 and 100."
  }
}

variable "tunnel2_rekey_fuzz_percentage" {
  description = "(Optional, Default 100) The percentage of the rekey window for the second VPN tunnel during which the rekey time is randomly selected. Valid value is between 0 and 100."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel2_rekey_fuzz_percentage == null || (var.tunnel2_rekey_fuzz_percentage >= 0 && var.tunnel2_rekey_fuzz_percentage <= 100)
    error_message = "Must be between 0 and 100."
  }
}

variable "tunnel1_rekey_margin_time_seconds" {
  description = "(Optional, Default 540) The margin time, in seconds, before the phase 2 lifetime expires, during which the AWS side of the first VPN connection performs an IKE rekey. Valid value is between 60 and half of tunnel1_phase2_lifetime_seconds."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel1_rekey_margin_time_seconds == null || var.tunnel1_rekey_margin_time_seconds >= 60
    error_message = "Must be >= 60."
  }
}

variable "tunnel2_rekey_margin_time_seconds" {
  description = "(Optional, Default 540) The margin time, in seconds, before the phase 2 lifetime expires, during which the AWS side of the second VPN connection performs an IKE rekey. Valid value is between 60 and half of tunnel2_phase2_lifetime_seconds."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel2_rekey_margin_time_seconds == null || var.tunnel2_rekey_margin_time_seconds >= 60
    error_message = "Must be >= 60."
  }
}

variable "tunnel1_replay_window_size" {
  description = "(Optional, Default 1024) The number of packets in an IKE replay window for the first VPN tunnel. Valid value is between 64 and 2048."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel1_replay_window_size == null || (var.tunnel1_replay_window_size >= 64 && var.tunnel1_replay_window_size <= 2048)
    error_message = "Must be between 64 and 2048."
  }
}

variable "tunnel2_replay_window_size" {
  description = "(Optional, Default 1024) The number of packets in an IKE replay window for the second VPN tunnel. Valid value is between 64 and 2048."
  type        = number
  default     = null

  validation {
    condition     = var.tunnel2_replay_window_size == null || (var.tunnel2_replay_window_size >= 64 && var.tunnel2_replay_window_size <= 2048)
    error_message = "Must be between 64 and 2048."
  }
}

variable "tunnel1_startup_action" {
  description = "(Optional, Default add) The action to take when establishing the tunnel for the first VPN connection. Valid values are add | start."
  type        = string
  default     = null

  validation {
    condition     = var.tunnel1_startup_action == null || contains(["add", "start"], var.tunnel1_startup_action)
    error_message = "Valid values are: add, start."
  }
}

variable "tunnel2_startup_action" {
  description = "(Optional, Default add) The action to take when establishing the tunnel for the second VPN connection. Valid values are add | start."
  type        = string
  default     = null

  validation {
    condition     = var.tunnel2_startup_action == null || contains(["add", "start"], var.tunnel2_startup_action)
    error_message = "Valid values are: add, start."
  }
}

variable "tunnel1_ike_versions" {
  description = "(Optional) The IKE versions that are permitted for the first VPN tunnel. Valid values are ikev1 | ikev2."
  type        = list(string)
  default     = null

  validation {
    condition     = var.tunnel1_ike_versions == null || alltrue([for v in var.tunnel1_ike_versions : contains(["ikev1", "ikev2"], v)])
    error_message = "Valid values are: ikev1, ikev2."
  }
}

variable "tunnel2_ike_versions" {
  description = "(Optional) The IKE versions that are permitted for the second VPN tunnel. Valid values are ikev1 | ikev2."
  type        = list(string)
  default     = null

  validation {
    condition     = var.tunnel2_ike_versions == null || alltrue([for v in var.tunnel2_ike_versions : contains(["ikev1", "ikev2"], v)])
    error_message = "Valid values are: ikev1, ikev2."
  }
}

variable "tunnel1_log_options" {
  description = "(Optional) Options for sending VPN tunnel logs to CloudWatch."
  type        = any
  default     = {}
}

variable "tunnel2_log_options" {
  description = "(Optional) Options for sending VPN tunnel logs to CloudWatch."
  type        = any
  default     = {}
}

variable "tunnel_inside_ip_version" {
  description = "(Optional) Indicate whether the VPN tunnels process IPv4 or IPv6 traffic. Valid values are ipv4 | ipv6. ipv6 Supports only EC2 Transit Gateway."
  type        = string
  default     = null

  validation {
    condition     = var.tunnel_inside_ip_version == null || contains(["ipv4", "ipv6"], var.tunnel_inside_ip_version)
    error_message = "Valid values are: ipv4, ipv6."
  }
}

variable "local_ipv4_network_cidr" {
  description = "(Optional) The IPv4 CIDR on the customer gateway (on-premises) side of the VPN connection."
  type        = string
  default     = null

  validation {
    condition     = var.local_ipv4_network_cidr == null || can(cidrhost(var.local_ipv4_network_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "remote_ipv4_network_cidr" {
  description = "(Optional) The IPv4 CIDR on the AWS side of the VPN connection."
  type        = string
  default     = null

  validation {
    condition     = var.remote_ipv4_network_cidr == null || can(cidrhost(var.remote_ipv4_network_cidr, 0))
    error_message = "Must be a valid IPv4 CIDR block."
  }
}

variable "local_ipv6_network_cidr" {
  description = "(Optional) The IPv6 CIDR on the customer gateway (on-premises) side of the VPN connection."
  type        = string
  default     = null
}

variable "remote_ipv6_network_cidr" {
  description = "(Optional) The IPv6 CIDR on AWS side of the VPN connection."
  type        = string
  default     = null
}

variable "tunnel1_enable_tunnel_lifecycle_control" {
  description = "(Optional) Turn on or off tunnel endpoint lifecycle control feature for the first VPN tunnel."
  type        = bool
  default     = null
}

variable "tunnel2_enable_tunnel_lifecycle_control" {
  description = "(Optional) Turn on or off tunnel endpoint lifecycle control feature for the second VPN tunnel."
  type        = bool
  default     = null
}
