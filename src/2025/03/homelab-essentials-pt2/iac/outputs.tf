output "talos_client_config" {
  description = "Talos client configuration containing the talosconfig"
  value       = module.talos.talos_client_config
  sensitive   = true
}

output "k8s_config" {
  description = "Kubernetes client configuration containing the kubeconfig"
  value       = module.talos.k8s_config
  sensitive   = true
}
