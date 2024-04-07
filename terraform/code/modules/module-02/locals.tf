locals {
  subnets_m2 = {
    snet-app-01 = {
      address_prefix                            = var.subnet_application_address_prefix
      private_endpoint_network_policies_enabled = false
      nsgrules = [
        "AllowVirtualNetworkInbound",
        "AllowVirtualNetworkOutbound",
        "AllowInternetOutbound"
      ]
    }

    snet-db-01 = {
      address_prefix                            = var.subnet_database_address_prefix
      private_endpoint_network_policies_enabled = false
      nsgrules = [
        "AllowVirtualNetworkInbound",
        "AllowVirtualNetworkOutbound",
        "AllowInternetOutbound"
      ]
    }

    snet-misc-03 = {
      address_prefix                            = var.subnet_misc_03_address_prefix
      private_endpoint_network_policies_enabled = false
      nsgrules = [
        "AllowVirtualNetworkInbound",
        "AllowVirtualNetworkOutbound",
        "AllowInternetOutbound"
      ]
    }

    snet-privatelink-01 = {
      address_prefix                            = var.subnet_privatelink_address_prefix
      private_endpoint_network_policies_enabled = true
      nsgrules = [
        "AllowVirtualNetworkInbound",
        "AllowVirtualNetworkOutbound"
      ]
    }
  }

  nsgrules_m2 = {
    AllowInternetOutbound = {
      access                     = "Allow"
      destination_address_prefix = "Internet"
      destination_port_ranges    = ["*"]
      direction                  = "Outbound"
      protocol                   = "*"
      source_address_prefix      = "*"
      source_port_ranges         = ["*"]
    }

    AllowVirtualNetworkInbound = {
      access                     = "Allow"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["*"]
      direction                  = "Inbound"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_ranges         = ["*"]
    }

    AllowVirtualNetworkOutbound = {
      access                     = "Allow"
      destination_address_prefix = "VirtualNetwork"
      destination_port_ranges    = ["*"]
      direction                  = "Outbound"
      protocol                   = "*"
      source_address_prefix      = "VirtualNetwork"
      source_port_ranges         = ["*"]
    }
  }

  network_security_group_rules_m2 = flatten([
    for subnet_key, subnet in local.subnets_m2 : [
      for nsgrule_key in subnet.nsgrules : {
        subnet_name                = subnet_key
        nsgrule_name               = nsgrule_key
        access                     = local.nsgrules_m2[nsgrule_key].access
        destination_address_prefix = local.nsgrules_m2[nsgrule_key].destination_address_prefix
        destination_port_ranges    = local.nsgrules_m2[nsgrule_key].destination_port_ranges
        direction                  = local.nsgrules_m2[nsgrule_key].direction
        priority                   = 100 + (index(subnet.nsgrules, nsgrule_key) * 10)
        protocol                   = local.nsgrules_m2[nsgrule_key].protocol
        source_address_prefix      = local.nsgrules_m2[nsgrule_key].source_address_prefix
        source_port_ranges         = local.nsgrules_m2[nsgrule_key].source_port_ranges
      }
    ]
  ])

  private_dns_zones = [
    "privatelink.database.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.mysql.database.azure.com"
  ]
}