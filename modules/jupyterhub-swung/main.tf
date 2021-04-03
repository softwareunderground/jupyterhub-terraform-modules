resource "null_resource" "dependency_getter" {
  triggers = {
    my_dependencies = join(",", var.dependencies)
  }
}

module "jupyterhub-helm" {
  source = "/Users/filippo/Work/jupyterhub-terraform-modules/modules/jupyterhub"

  jupyterhub_helm_chart_version = var.jupyterhub_helm_chart_version

  namespace = var.namespace

  overrides-values = concat(var.jupyterhub-overrides-values, [
    jsonencode({
      hub = {
        nodeSelector = {
          "${var.general-node-group.key}" = var.general-node-group.value
        }

        image = var.jupyterhub-image

        services = {
          "dask-gateway" = {
            apiToken = module.dask-gateway-helm.jupyterhub_api_token
          }
        }
      }

      scheduling = {
        userScheduler = {
          nodeSelector = {
            "${var.general-node-group.key}" = var.general-node-group.value
          }
        }
      }

      proxy = {
        nodeSelector = {
          "${var.general-node-group.key}" = var.general-node-group.value
        }
      }

      singleuser = {
        nodeSelector = {
          "${var.user-node-group.key}" = var.user-node-group.value
        }

        image = var.jupyterlab-image

        storage = {
          static = {
            pvcName = var.home-pvc
          }

          extraVolumes = [
            {
              name = "conda-store"
              persistentVolumeClaim = {
                claimName = var.conda-store-pvc
              }
            },
            {
              name = "etc-dask"
              configMap = {
                name = kubernetes_config_map.dask-etc.metadata.0.name
              }
            }
          ]

          extraVolumeMounts = [
            {
              name      = "conda-store"
              mountPath = "/home/conda"
            },
            {
              name      = "etc-dask"
              mountPath = "/etc/dask"
            },
            {
              name      = "home"
              mountPath = "/home/shared"
              subPath   = "home/shared"
            }
          ]
        }
      }
    })
  ])

  dependencies = var.dependencies
}

module "dask-gateway-helm" {
  source = "/Users/filippo/Work/jupyterhub-terraform-modules/modules/dask-gateway"

  namespace = var.namespace

  external_endpoint = "https://${var.external-url}"

  overrides-values = concat(var.dask-gateway-overrides-values, [
    jsonencode({
      gateway = {
        clusterManager = {

          # Since we are using autoscaling nodes and pods take
          # longer to spin up
          clusterStartTimeout = 300 # 5 minutes
          workerStartTimeout  = 300 # 5 minutes

          image = var.dask-worker-image

          scheduler = {
            extraContainerConfig = {
              volumeMounts = [
                {
                  name      = "conda-store"
                  mountPath = "/home/conda"
                }
              ]
            }
            extraPodConfig = {
              affinity = local.affinity.worker-nodegroup
              volumes = [
                {
                  name = "conda-store"
                  persistentVolumeClaim = {
                    claimName = var.conda-store-pvc
                  }
                }
              ]
            }
          }
          worker = {
            extraContainerConfig = {
              volumeMounts = [
                {
                  name      = "conda-store"
                  mountPath = "/home/conda"
                }
              ]
            }
            extraPodConfig = {
              affinity = local.affinity.worker-nodegroup
              volumes = [
                {
                  name = "conda-store"
                  persistentVolumeClaim = {
                    claimName = var.conda-store-pvc
                  }
                }
              ]
            }
          }
        }
      }
    })
  ])

  dependencies = concat(var.dependencies, [module.jupyterhub-helm.depended_on])
}

resource "kubernetes_config_map" "dask-etc" {
  metadata {
    name      = "dask-etc"
    namespace = var.namespace
  }

  data = {
    "gateway.yaml"   = jsonencode(module.dask-gateway-helm.config)
    "dashboard.yaml" = jsonencode({})
  }
  depends_on = [null_resource.dependency_getter]
}

resource "kubernetes_ingress" "dask-gateway" {
  metadata {
    name      = "dask-gateway"
    namespace = var.namespace

    annotations = {
      "cert-manager.io/cluster-issuer"              = "letsencrypt-production"
      "kubernetes.io/ingress.class"                 = "nginx"
      "nginx.ingress.kubernetes.io/proxy-body-size" = "0"
    }
  }

  spec {
    rule {
      host = var.external-url
      http {
        path {
          backend {
            service_name = "web-public-dask-gateway"
            service_port = 80
          }

          path = "/gateway"
        }

        path {
          backend {
            service_name = "proxy-public"
            service_port = 80
          }

          path = "/"
        }
      }
    }

    tls {
      secret_name = "swunghub-cert"
      hosts       = [var.external-url]
    }
  }

  depends_on = [null_resource.dependency_getter]
}

resource "null_resource" "dependency_setter" {
  depends_on = [
    # List resource(s) that will be constructed last within the module.
  ]
}
