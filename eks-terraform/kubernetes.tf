provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  token                  = data.aws_eks_cluster_auth.cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
}


resource "kubernetes_namespace" "test" {
  # for_each = {for i,v in var.namespace_list: i=>v}
  count = length(var.namespace_list)
  metadata {
    name = var.namespace_list["${count.index}"].Namespace-Name
  }
}
resource "kubernetes_deployment" "test" {
  # for_each = {for i,v in var.namespace_list: i=>v}
  count = length(var.namespace_list)
  metadata {
    name      = var.namespace_list["${count.index}"].Deployment-Name
    namespace = var.namespace_list["${count.index}"].Namespace-Name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "MyTestApp"
      }
    }
    template {
      metadata {
        labels = {
          app = "MyTestApp"
        }
      }
      spec {
        container {
          image = "nginx"
          name  = "nginx-container"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}
resource "kubernetes_service" "test" {
  # for_each = {for i,v in var.namespace_list: i=>v}
  count = length(var.namespace_list)
  metadata {
    name      = var.namespace_list["${count.index}"].Service-Name
    namespace = var.namespace_list["${count.index}"].Namespace-Name
  }
  spec {
    selector = {
      # app = kubernetes_deployment.test.spec.0.template.0.metadata.0.labels.app
      app = var.namespace_list["${count.index}"].Namespace-Name
    }
    type = "LoadBalancer"
    port {
      port        = 80
      target_port = 80
    }
  }
}
