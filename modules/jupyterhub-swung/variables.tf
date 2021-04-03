variable "namespace" {
  description = "Namespace for the JupyterHub deployment"
  type        = string
}

variable "jupyterhub_helm_chart_version" {
  description = "JupyterHub Helm chart version"
  type        = string
}

variable "home-pvc" {
  description = "Name for persistent volume claim to use for home directory uses /home/{username}"
  type        = string
}

variable "conda-store-pvc" {
  description = "Name for persistent volume claim to use for conda-store directory"
  type        = string
}

variable "external-url" {
  description = "External url for the JupyterHub cluster"
  type        = string
}

variable "jupyterhub-image" {
  description = "Docker image to use for JupyterHub hub"
  type = object({
    name = string
    tag  = string
  })
}

variable "jupyterlab-image" {
  description = "Docker image to use for the Jupyter lab servers"
  type = object({
    name = string
    tag  = string
  })
}

variable "dask-worker-image" {
  description = "Docker image to use for dask worker image"
  type = object({
    name = string
    tag  = string
  })
}

variable "general-node-group" {
  description = "Node key value pair for bound general resources"
  type = object({
    key   = string
    value = string
  })
}

variable "user-node-group" {
  description = "Node group key value pair for bound user resources"
  type = object({
    key   = string
    value = string
  })
}

variable "worker-node-group" {
  description = "Node group key value pair for bound worker resources"
  type = object({
    key   = string
    value = string
  })
}

variable "jupyterhub-overrides-values" {
  description = "Jupyterhub helm values overrides"
  type        = list(string)
}

variable "dask-gateway-overrides-values" {
  description = "Dask Worker helm values overrides"
  type        = list(string)
  default     = []
}

variable "dependencies" {
  description = "A list of module dependencies to be injected in the module"
  type        = list(any)
  default     = []
}
