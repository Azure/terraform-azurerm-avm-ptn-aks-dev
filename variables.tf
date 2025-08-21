variable "location" {
  type        = string
  description = "The Azure region where the resources should be deployed."
  nullable    = false
}

variable "name" {
  type        = string
  description = "The name for the AKS resources created in the specified Azure Resource Group. This variable overwrites the 'prefix' var (The 'prefix' var will still be applied to the dns_prefix if it is set)"

  validation {
    condition     = can(regex("^[a-zA-Z0-9]$|^[a-zA-Z0-9][-_a-zA-Z0-9]{0,61}[a-zA-Z0-9]$", var.name))
    error_message = "Check naming rules here https://learn.microsoft.com/en-us/rest/api/aks/managed-clusters/create-or-update?view=rest-aks-2023-10-01&tabs=HTTP"
  }
}

# This is required for most resource modules
variable "resource_group_name" {
  type        = string
  description = "The resource group where the resources will be deployed."
  nullable    = false
}

variable "agents_tags" {
  type        = map(string)
  default     = null
  description = "(Optional) A mapping of tags to assign to the Node Pool."
}

variable "container_registry_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the container registry to use for the AKS cluster."
}

variable "enable_telemetry" {
  type        = bool
  default     = true
  description = <<DESCRIPTION
This variable controls whether or not telemetry is enabled for the module.
For more information see <https://aka.ms/avm/telemetryinfo>.
If it is set to false, then no telemetry will be collected.
DESCRIPTION
  nullable    = false
}

variable "kubernetes_version" {
  type        = string
  default     = null
  description = "(Optional) Specify which Kubernetes release to use. Specify only minor version, such as '1.30'."

  validation {
    condition     = var.kubernetes_version == null || try(can(regex("^[0-9]+\\.[0-9]+$", var.kubernetes_version)), false)
    error_message = "Ensure that kubernetes_version does not specify a patch version"
  }
}

variable "lock" {
  type = object({
    kind = string
    name = optional(string, null)
  })
  default     = null
  description = <<DESCRIPTION
(Optional) Controls the Resource Lock configuration for this resource. The following properties can be specified:

  - `kind` - (Required) The type of lock. Possible values are `\"CanNotDelete\"` and `\"ReadOnly\"`.
  - `name` - (Optional) The name of the lock. If not specified, a name will be generated based on the `kind` value. Changing this forces the creation of a new resource.
  DESCRIPTION

  validation {
    condition     = var.lock != null ? contains(["CanNotDelete", "ReadOnly"], var.lock.kind) : true
    error_message = "Lock kind must be either `\"CanNotDelete\"` or `\"ReadOnly\"`."
  }
}

variable "orchestrator_version" {
  type        = string
  default     = null
  description = "(Optional) Specify which Kubernetes release to use. Specify only minor version, such as '1.30'."

  validation {
    condition     = var.orchestrator_version == null || try(can(regex("^[0-9]+\\.[0-9]+$", var.orchestrator_version)), false)
    error_message = "Ensure that orchestrator_version does not specify a patch version"
  }
}

variable "rbac_aad_admin_group_object_ids" {
  type        = list(string)
  default     = null
  description = "(Optional) Object ID of groups with admin access."
}

variable "rbac_aad_azure_rbac_enabled" {
  type        = bool
  default     = null
  description = "(Optional) Is Role Based Access Control based on Azure AD enabled?"
}

variable "rbac_aad_tenant_id" {
  type        = string
  default     = null
  description = "(Optional) The Tenant ID used for Azure Active Directory Application. If this isn't specified the Tenant ID of the current Subscription is used."
}

# tflint-ignore: terraform_unused_declarations
variable "tags" {
  type        = map(string)
  default     = null
  description = "(Optional) Tags of the resource."
}

variable "user_assigned_identity_name" {
  type        = string
  default     = null
  description = "(Optional) The name of the User Assigned Managed Identity to create."
}

variable "user_assigned_managed_identity_resource_ids" {
  type        = set(string)
  default     = []
  description = "(Optional) Specifies a list of User Assigned Managed Identity resource IDs to be assigned to this resource."
  nullable    = false
}
