
resource "random_string" "acr_suffix" {
  length  = 8
  numeric = true
  special = false
  upper   = false
}

resource "azurerm_container_registry" "this" {
  location            = var.location
  name                = coalesce(var.container_registry_name, "cr${random_string.acr_suffix.result}")
  resource_group_name = var.resource_group_name
  sku                 = "Premium"
  tags                = var.tags
}

resource "azurerm_role_assignment" "acr" {
  principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
  scope                            = azurerm_container_registry.this.id
  role_definition_name             = "AcrPull"
  skip_service_principal_aad_check = true
}

resource "azurerm_user_assigned_identity" "aks" {
  count = length(var.user_assigned_managed_identity_resource_ids) > 0 ? 0 : 1

  location            = var.location
  name                = coalesce(var.user_assigned_identity_name, "uami-aks")
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  location                          = var.location
  name                              = "aks-${var.name}"
  resource_group_name               = var.resource_group_name
  automatic_upgrade_channel         = "patch"
  dns_prefix                        = var.name
  kubernetes_version                = var.kubernetes_version
  node_os_upgrade_channel           = "NodeImage"
  oidc_issuer_enabled               = true
  role_based_access_control_enabled = true
  sku_tier                          = "Free"
  tags                              = var.tags
  workload_identity_enabled         = true

  default_node_pool {
    name                    = "agentpool"
    auto_scaling_enabled    = true
    host_encryption_enabled = true
    max_count               = 5
    max_pods                = 110
    min_count               = 2
    orchestrator_version    = var.orchestrator_version
    os_sku                  = "Ubuntu"
    tags                    = merge(var.tags, var.agents_tags)
    vm_size                 = "Standard_DS2_v2"

    upgrade_settings {
      max_surge = "10%"
    }
  }
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.rbac_aad_azure_rbac_enabled == true ? [1] : []

    content {
      admin_group_object_ids = var.rbac_aad_admin_group_object_ids
      azure_rbac_enabled     = var.rbac_aad_azure_rbac_enabled
      tenant_id              = var.rbac_aad_tenant_id
    }
  }
  identity {
    type         = "UserAssigned"
    identity_ids = length(var.user_assigned_managed_identity_resource_ids) > 0 ? var.user_assigned_managed_identity_resource_ids : azurerm_user_assigned_identity.aks[*].id
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "basic"
    network_policy    = "calico"
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version
    ]
  }
}

# The following terraform_data is used to trigger the update of the AKS cluster when the kubernetes_version changes
# This is necessary because the azurerm_kubernetes_cluster resource ignores changes to the kubernetes_version attribute
# because AKS patch versions are upgraded automatically by Azure
# The kubernetes_version_keeper and aks_cluster_post_create resources implement a mechanism to force the update
# when the minor kubernetes version changes in var.kubernetes_version

resource "terraform_data" "kubernetes_version_keeper" {
  triggers_replace = {
    version = var.kubernetes_version
  }
}

resource "azapi_update_resource" "aks_cluster_post_create" {
  resource_id = azurerm_kubernetes_cluster.this.id
  type        = "Microsoft.ContainerService/managedClusters@2024-02-01"
  body = {
    properties = {
      kubernetesVersion = var.kubernetes_version
    }
  }
  read_headers   = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null
  update_headers = var.enable_telemetry ? { "User-Agent" : local.avm_azapi_header } : null

  lifecycle {
    ignore_changes       = all
    replace_triggered_by = [terraform_data.kubernetes_version_keeper.id]
  }
}

# required AVM resources interfaces
resource "azurerm_management_lock" "this" {
  count = var.lock != null ? 1 : 0

  lock_level = var.lock.kind
  name       = coalesce(var.lock.name, "lock-${var.lock.kind}")
  scope      = azurerm_kubernetes_cluster.this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}