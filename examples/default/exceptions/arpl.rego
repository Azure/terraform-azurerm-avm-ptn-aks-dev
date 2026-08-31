package Azure_Proactive_Resiliency_Library_v2
 
import rego.v1
 
exception contains rules if {
  rules = [
    "configure_aks_default_node_pool_zones",
    # This is a dev/test pattern module, so the Free SKU tier is deliberate.
    # Production callers should set a paid tier via the AKS resource module.
    "aks_sku_standard_or_premium",
  ]
}