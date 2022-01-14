output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}

output "jupyterhub_api_token" {
  description = "API token to enable in jupyterhub server"
  value       = module.dask-gateway-helm.jupyterhub_api_token
}

output "jupyterhub_values" {
  description = "Final version of the values passed to the Helm chart"
  value       = module.jupyterhub-helm.jupyterhub_values
}

