output "depended_on" {
  value = "${null_resource.dependency_setter.id}-${timestamp()}"
}

output "jupyterhub_values" {
#output "jupyterhub_overrides" {
  description = "Final version of the values passed to the Helm chart"
  value = helm_release.jupyterhub.metadata[0].values
}

