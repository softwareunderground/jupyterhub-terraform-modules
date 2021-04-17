resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = join(",", var.dependencies)
  }
}

#data "helm_repository" "jupyterhub" {
#  name = "jupyterhub"
#  url  = "https://jupyterhub.github.io/helm-chart/"
#}

resource "random_password" "proxy_secret_token" {
  length  = 32
  special = false
}

resource "helm_release" "jupyterhub" {
  name      = "jupyterhub"
  namespace = var.namespace

  repository = "https://jupyterhub.github.io/helm-chart/"
  # repository = data.helm_repository.jupyterhub.metadata[0].name
  chart      = "jupyterhub"
  version    = "0.9.0-beta.3"

  # List of values in raw yaml to pass to helm. Values will be merged, in order, as Helm does with multiple -f options
  values = concat([
    file("${path.module}/values.yaml"),
  ], var.overrides)

  # Value block with custom values to be merged with the values yaml
  set {
    name  = "proxy.secretToken"
    value = random_password.proxy_secret_token.result
  }

  depends_on = [
    null_resource.dependency_getter
  ]
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    helm_release.jupyterhub
    # List resource(s) that will be constructed last within the module.
  ]
}
