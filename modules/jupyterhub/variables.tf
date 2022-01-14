variable "jupyterhub_helm_chart_version" {
  description = "JupyterHub Helm chart version"
  type        = string
}

variable "namespace" {
  description = "Namespace for the JupyterHub deployment"
  type        = string
}

variable "overrides-values" {
  description = "Jupyterhub helm chart list of values overrides"
  type        = list(string)
  default     = []
}

variable "dependencies" {
  description = "A list of module dependencies to be injected in the module"
  type        = list(any)
  default     = []
}

