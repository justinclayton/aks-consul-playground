# variable "client_id" {}
# variable "client_secret" {}

# variable "agent_count" {
#     default = 3
# }

variable "subscription_id" {}

variable "ssh_public_key" {
    default = "~/.ssh/id_rsa.pub"
}

variable "dns_prefix" {
    default = "k8stest"
}

variable cluster_name {
    default = "k8stest"
}

variable resource_group_name {
    default = "azure-k8stest"
}

variable location {
    default = "westus2"
    description = "Azure Region"
}

variable log_analytics_workspace_name {
    default = "testLogAnalyticsWorkspaceName"
}

# refer https://azure.microsoft.com/global-infrastructure/services/?products=monitor for log analytics available regions
variable log_analytics_workspace_location {
    default = "westus2"
}

# refer https://azure.microsoft.com/pricing/details/monitor/ for log analytics pricing 
variable log_analytics_workspace_sku {
    default = "PerGB2018"
}

variable version_1 {
    default = "1.20.15"
}

variable version_2 {
    default = "1.21.9"
}

variable vm_size {
    default = "Standard_D2_v5"
}
