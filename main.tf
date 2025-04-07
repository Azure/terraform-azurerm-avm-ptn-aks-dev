resource "random_string" "acr_suffix" {
  length  = 8
  numeric = true
  special = false
  upper   = false
}

# resource "azurerm_container_registry" "this" {
#   location            = var.location
#   name                = coalesce(var.container_registry_name, "cr${random_string.acr_suffix.result}")
#   resource_group_name = var.resource_group_name
#   sku                 = "Premium"
#   tags                = var.tags
# }
# 
moved {
  from = azurerm_container_registry.this
  to   = azapi_resource.registry_this
}

resource "azapi_resource" "registry_this" {
  type      = "Microsoft.ContainerRegistry/registries@2024-11-01-preview"
  parent_id = "/subscriptions/dbf3b6cb-c1d0-4d04-94b9-51509b8d33fd/resourceGroups/rg-demo-aks"
  name      = "crtromv8i3"
  location  = var.location
  body = {
    properties = {
      adminUserEnabled     = false
      anonymousPullEnabled = false
      dataEndpointEnabled  = false
      encryption = {
        status = "disabled"
      }
      metadataSearch           = "Disabled"
      networkRuleBypassOptions = "AzureServices"
      networkRuleSet = {
        defaultAction = "Allow"
        ipRules       = []
      }
      policies = {
        azureADAuthenticationAsArmPolicy = {
          status = "enabled"
        }
        exportPolicy = {
          status = "enabled"
        }
        quarantinePolicy = {
          status = "disabled"
        }
        retentionPolicy = {
          days   = 7
          status = "disabled"
        }
        softDeletePolicy = {
          retentionDays = 7
          status        = "disabled"
        }
        trustPolicy = {
          status = "disabled"
          type   = "Notary"
        }
      }
      publicNetworkAccess = "Enabled"
      zoneRedundancy      = "Disabled"
    }
    sku = {
      name = "Premium"
    }
  }
  schema_validation_enabled = true
  ignore_casing             = false
  ignore_missing_property   = true
}

# resource "azurerm_role_assignment" "acr" {
#   principal_id                     = azurerm_kubernetes_cluster.this.kubelet_identity[0].object_id
#   scope                            = azurerm_container_registry.this.id
#   role_definition_name             = "AcrPull"
#   skip_service_principal_aad_check = true
# }
# 
moved {
  from = azurerm_role_assignment.acr
  to   = azapi_resource.roleAssignment_acr
}

resource "azapi_resource" "roleAssignment_acr" {
  type      = "Microsoft.Authorization/roleAssignments@2022-04-01"
  parent_id = azapi_resource.registry_this.id
  name      = "295b9979-7772-d89a-e25d-dcd0d53e7c3d"
  body = {
    properties = {
      condition                          = null
      conditionVersion                   = null
      delegatedManagedIdentityResourceId = null
      description                        = ""
      principalId                        = "51276b3f-69b1-46b1-a1be-7790fccf3c0a"
      principalType                      = "ServicePrincipal"
      roleDefinitionId                   = "/subscriptions/dbf3b6cb-c1d0-4d04-94b9-51509b8d33fd/providers/Microsoft.Authorization/roleDefinitions/7f951dda-4ed3-4680-a7ca-43fe172d538d"
    }
  }
  schema_validation_enabled = true
  ignore_casing             = false
  ignore_missing_property   = true
}

# resource "azurerm_user_assigned_identity" "aks" {
#   count = length(var.user_assigned_managed_identity_resource_ids) > 0 ? 0 : 1
# 
#   location            = var.location
#   name                = coalesce(var.user_assigned_identity_name, "uami-aks")
#   resource_group_name = var.resource_group_name
#   tags                = var.tags
# }
# 
moved {
  from = azurerm_user_assigned_identity.aks
  to   = azapi_resource.userAssignedIdentity_aks
}

resource "azapi_resource" "userAssignedIdentity_aks" {
  count                     = 1
  type                      = "Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30"
  parent_id                 = "/subscriptions/dbf3b6cb-c1d0-4d04-94b9-51509b8d33fd/resourceGroups/rg-demo-aks"
  name                      = "uami-aks"
  location                  = var.location
  body                      = {}
  ignore_missing_property   = true
  ignore_casing             = false
  schema_validation_enabled = true
}

# resource "azurerm_kubernetes_cluster" "this" {
#   location                          = var.location
#   name                              = "aks-${var.name}"
#   resource_group_name               = var.resource_group_name
#   automatic_upgrade_channel         = "patch"
#   dns_prefix                        = var.name
#   kubernetes_version                = var.kubernetes_version
#   node_os_upgrade_channel           = "NodeImage"
#   oidc_issuer_enabled               = true
#   role_based_access_control_enabled = true
#   sku_tier                          = "Free"
#   tags                              = var.tags
#   workload_identity_enabled         = true
# 
#   default_node_pool {
#     name                    = "agentpool"
#     vm_size                 = "Standard_DS2_v2"
#     auto_scaling_enabled    = true
#     host_encryption_enabled = true
#     max_count               = 5
#     max_pods                = 110
#     min_count               = 2
#     orchestrator_version    = var.orchestrator_version
#     os_sku                  = "Ubuntu"
#     tags                    = merge(var.tags, var.agents_tags)
# 
#     upgrade_settings {
#       max_surge = "10%"
#     }
#   }
#   dynamic "azure_active_directory_role_based_access_control" {
#     for_each = var.rbac_aad_azure_rbac_enabled == true ? [1] : []
# 
#     content {
#       admin_group_object_ids = var.rbac_aad_admin_group_object_ids
#       azure_rbac_enabled     = var.rbac_aad_azure_rbac_enabled
#       tenant_id              = var.rbac_aad_tenant_id
#     }
#   }
#   identity {
#     type         = "UserAssigned"
#     identity_ids = length(var.user_assigned_managed_identity_resource_ids) > 0 ? var.user_assigned_managed_identity_resource_ids : azurerm_user_assigned_identity.aks[*].id
#   }
#   network_profile {
#     network_plugin    = "kubenet"
#     load_balancer_sku = "basic"
#     network_policy    = "calico"
#   }
# 
#   lifecycle {
#     ignore_changes = [
#       kubernetes_version
#     ]
#   }
# }
# 
moved {
  from = azurerm_kubernetes_cluster.this
  to   = azapi_resource.managedCluster_this
}

resource "azapi_resource" "managedCluster_this" {
  type      = "Microsoft.ContainerService/managedClusters@2024-10-02-preview"
  parent_id = "/subscriptions/dbf3b6cb-c1d0-4d04-94b9-51509b8d33fd/resourceGroups/rg-demo-aks"
  name      = "aks-demo-aks"
  location  = var.location
  identity {
    identity_ids = ["/subscriptions/dbf3b6cb-c1d0-4d04-94b9-51509b8d33fd/resourceGroups/rg-demo-aks/providers/Microsoft.ManagedIdentity/userAssignedIdentities/uami-aks"]
    type         = "UserAssigned"
  }
  body = {
    sku = {
      name = "Base"
      tier = "Free"
    }
    kind = "Base"
    properties = {
      azureMonitorProfile = {
        metrics = {
          enabled          = false
          kubeStateMetrics = {}
        }
      }
      disableLocalAccounts = false
      dnsPrefix            = var.name
      kubernetesVersion    = "1.30"
      oidcIssuerProfile = {
        enabled = true
      }
      storageProfile = {
        fileCSIDriver = {
          enabled = true
        }
        snapshotController = {
          enabled = true
        }
        diskCSIDriver = {
          enabled = true
          version = "v1"
        }
      }
      agentPoolProfiles = [
        {
          maxCount            = 5
          osDiskSizeGB        = 128
          osDiskType          = "Managed"
          type                = "VirtualMachineScaleSets"
          enableFIPS          = false
          minCount            = 2
          orchestratorVersion = "1.30"
          osSKU               = "Ubuntu"
          securityProfile = {
            enableSecureBoot = false
            enableVTPM       = false
            sshAccess        = "LocalUser"
          }
          upgradeSettings = {
            maxUnavailable            = "0"
            nodeSoakDurationInMinutes = 0
            maxSurge                  = "10%"
          }
          enableUltraSSD         = false
          enableEncryptionAtHost = true
          enableNodePublicIP     = false
          kubeletDiskType        = "OS"
          name                   = "agentpool"
          osType                 = "Linux"
          powerState = {
            code = "Running"
          }
          scaleDownMode     = "Delete"
          enableAutoScaling = true
          maxPods           = 110
          mode              = "System"
          vmSize            = "Standard_DS2_v2"
          count             = 2
        }
      ]
      autoScalerProfile = {
        scan-interval                         = "10s"
        skip-nodes-with-local-storage         = "false"
        balance-similar-node-groups           = "false"
        max-graceful-termination-sec          = "600"
        scale-down-unneeded-time              = "10m"
        scale-down-delay-after-add            = "10m"
        daemonset-eviction-for-occupied-nodes = true
        ignore-daemonsets-utilization         = false
        ok-total-unready-count                = "3"
        scale-down-delay-after-failure        = "3m"
        skip-nodes-with-system-pods           = "true"
        expander                              = "random"
        new-pod-scale-up-delay                = "0s"
        scale-down-delay-after-delete         = "10s"
        max-total-unready-percentage          = "45"
        scale-down-unready-time               = "20m"
        scale-down-utilization-threshold      = "0.5"
        daemonset-eviction-for-empty-nodes    = false
        max-empty-bulk-delete                 = "10"
        max-node-provision-time               = "15m"
      }
      autoUpgradeProfile = {
        nodeOSUpgradeChannel = "NodeImage"
        upgradeChannel       = "patch"
      }
      enableRBAC = true
      metricsProfile = {
        costAnalysis = {
          enabled = false
        }
      }
      networkProfile = {
        podCidrs = [
          "10.244.0.0/16"
        ]
        serviceCidr = "10.0.0.0/16"
        serviceCidrs = [
          "10.0.0.0/16"
        ]
        dnsServiceIP = "10.0.0.10"
        ipFamilies = [
          "IPv4"
        ]
        loadBalancerSku    = "basic"
        networkPlugin      = "kubenet"
        podCidr            = "10.244.0.0/16"
        networkPolicy      = "calico"
        outboundType       = "loadBalancer"
        podLinkLocalAccess = "IMDS"
      }
      addonProfiles = {
        azurepolicy = {
          config  = null
          enabled = true
        }
      }
      nodeProvisioningProfile = {
        mode = "Manual"
      }
      servicePrincipalProfile = {
        clientId = "msi"
      }
      supportPlan               = "KubernetesOfficial"
      workloadAutoScalerProfile = {}
      bootstrapProfile = {
        artifactSource = "Direct"
      }
      identityProfile = {
        kubeletidentity = {
          clientId   = "3b4f8b70-a7f3-4edc-9239-0af2906b0654"
          objectId   = "51276b3f-69b1-46b1-a1be-7790fccf3c0a"
          resourceId = "/subscriptions/dbf3b6cb-c1d0-4d04-94b9-51509b8d33fd/resourcegroups/MC_rg-demo-aks_aks-demo-aks_westus3/providers/Microsoft.ManagedIdentity/userAssignedIdentities/aks-demo-aks-agentpool"
        }
      }
      nodeResourceGroup = "MC_rg-demo-aks_aks-demo-aks_westus3"
      securityProfile = {
        workloadIdentity = {
          enabled = true
        }
      }
    }
  }
  ignore_missing_property   = true
  schema_validation_enabled = true
  ignore_casing             = false
  lifecycle {
    ignore_changes = [
      kubernetes_version
    ]
  }
}

resource "terraform_data" "kubernetes_version_keeper" {
  triggers_replace = {
    version = var.kubernetes_version
  }
}

resource "azapi_update_resource" "aks_cluster_post_create" {
  type = "Microsoft.ContainerService/managedClusters@2024-02-01"
  body = {
    properties = {
      kubernetesVersion = var.kubernetes_version
    }
  }
  resource_id = azapi_resource.managedCluster_this.id

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
  scope      = azapi_resource.managedCluster_this.id
  notes      = var.lock.kind == "CanNotDelete" ? "Cannot delete the resource or its child resources." : "Cannot delete or modify the resource or its child resources."
}

