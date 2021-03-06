resource "kubernetes_manifest" "servicemonitor_thanos_query" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "monitoring.coreos.com/v1"
    "kind" = "ServiceMonitor"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "query-layer"
        "app.kubernetes.io/instance" = "thanos-query"
        "app.kubernetes.io/name" = "thanos-query"
        "app.kubernetes.io/version" = "v0.17.2"
      }
      "name" = "thanos-query"
      "namespace" = kubernetes_manifest.namespace_thanos.object.metadata.name
    }
    "spec" = {
      "endpoints" = [
        {
          "port" = "http"
          "relabelings" = [
            {
              "separator" = "/"
              "sourceLabels" = [
                "namespace",
                "pod",
              ]
              "targetLabel" = "instance"
            },
          ]
        },
      ]
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "query-layer"
          "app.kubernetes.io/instance" = "thanos-query"
          "app.kubernetes.io/name" = "thanos-query"
        }
      }
    }
  }
}
