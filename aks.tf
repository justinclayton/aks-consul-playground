resource "azurerm_resource_group" "k8s" {
    name     = var.resource_group_name
    location = var.location
}

resource "random_id" "log_analytics_workspace_name_suffix" {
    byte_length = 8
}

resource "azurerm_log_analytics_workspace" "test" {
    # The WorkSpace name has to be unique across the whole of azure, not just the current subscription/tenant.
    name                = "${var.log_analytics_workspace_name}-${random_id.log_analytics_workspace_name_suffix.dec}"
    location            = var.log_analytics_workspace_location
    resource_group_name = azurerm_resource_group.k8s.name
    sku                 = var.log_analytics_workspace_sku
}

resource "azurerm_log_analytics_solution" "test" {
    solution_name         = "ContainerInsights"
    location              = azurerm_log_analytics_workspace.test.location
    resource_group_name   = azurerm_resource_group.k8s.name
    workspace_resource_id = azurerm_log_analytics_workspace.test.id
    workspace_name        = azurerm_log_analytics_workspace.test.name

    plan {
        publisher = "Microsoft"
        product   = "OMSGallery/ContainerInsights"
    }
}

resource "azurerm_kubernetes_cluster" "k8s" {
    name                = var.cluster_name
    location            = azurerm_resource_group.k8s.location
    resource_group_name = azurerm_resource_group.k8s.name
    dns_prefix          = var.dns_prefix
    kubernetes_version  = var.version_1

    linux_profile {
        admin_username = "ubuntu"

        ssh_key {
            key_data = file(var.ssh_public_key)
        }
    }

    default_node_pool {
        name            = "agentpool"
        node_count      = 2
        vm_size         = "Standard_D2_v5"
        orchestrator_version = var.version_1
    }

    identity {
      type = "SystemAssigned"
    }

    # service_principal {
    #     client_id     = var.client_id
    #     client_secret = var.client_secret
    # }

    addon_profile {
        oms_agent {
        enabled                    = true
        log_analytics_workspace_id = azurerm_log_analytics_workspace.test.id
        }
    }

    network_profile {
        load_balancer_sku = "Standard"
        network_plugin = "kubenet"
    }

    tags = {
        Environment = "Development"
    }
}

resource "azurerm_kubernetes_cluster_node_pool" "secondpool" {
  name                  = "secondpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
#   vm_size               = "Standard_DS2_v5"
  vm_size               = "Standard_D2_v5"
  node_count            = 2
  orchestrator_version  = var.version_2

  tags = {
    Environment = "secondpool"
  }
}

# resource "azurerm_kubernetes_cluster_node_pool" "thirdpool" {
#   name                  = "thirdpool"
#   kubernetes_cluster_id = azurerm_kubernetes_cluster.k8s.id
#   vm_size               = "Standard_D2_v5"
#   node_count            = 1
#   orchestrator_version  = var.version_1

#   tags = {
#     Environment = "thirdpool"
#   }
# }