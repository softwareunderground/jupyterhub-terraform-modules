resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = join(",", var.dependencies)
  }
}

resource "random_password" "cookie_secret_token" {
  length  = 32
  special = false
}

resource "random_password" "proxy_secret_token" {
  length  = 32
  special = false
}

resource "random_password" "jupyterhub_api_token" {
  length  = 32
  special = false
}

resource "helm_release" "dask-gateway" {
  name      = var.name
  namespace = var.namespace

  repository = "https://dask.org/dask-gateway-helm-repo/"
  chart      = "dask-gateway"
  version    = "0.6.1"

  values = concat([
    file("${path.module}/values.yaml")
  ], var.overrides-values)

  set {
    name  = "gateway.cookieSecret"
    value = random_password.cookie_secret_token.result
  }

  set {
    name  = "gateway.secretToken"
    value = random_password.proxy_secret_token.result
  }

  set {
    name  = "gateway.auth.jupyterhub.apiToken"
    value = random_password.jupyterhub_api_token.result
  }
  depends_on = [
    null_resource.dependency_getter
  ]
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    # List resource(s) that will be constructed last within the module.
  ]
}
