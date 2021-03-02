resource "kubernetes_manifest" "deployment_thanos_query" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "Deployment"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "query-layer"
        "app.kubernetes.io/instance" = "thanos-query"
        "app.kubernetes.io/name" = "thanos-query"
        "app.kubernetes.io/version" = "v0.17.2"
      }
      "name" = "thanos-query"
      "namespace" = "thanos"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "query-layer"
          "app.kubernetes.io/instance" = "thanos-query"
          "app.kubernetes.io/name" = "thanos-query"
        }
      }
      "template" = {
        "metadata" = {
          "labels" = {
            "app.kubernetes.io/component" = "query-layer"
            "app.kubernetes.io/instance" = "thanos-query"
            "app.kubernetes.io/name" = "thanos-query"
            "app.kubernetes.io/version" = "v0.17.2"
          }
        }
        "spec" = {
          "affinity" = {
            "podAntiAffinity" = {
              "preferredDuringSchedulingIgnoredDuringExecution" = [
                {
                  "podAffinityTerm" = {
                    "labelSelector" = {
                      "matchExpressions" = [
                        {
                          "key" = "app.kubernetes.io/name"
                          "operator" = "In"
                          "values" = [
                            "thanos-query",
                          ]
                        },
                      ]
                    }
                    "namespaces" = [
                      "thanos",
                    ]
                    "topologyKey" = "kubernetes.io/hostname"
                  }
                  "weight" = 100
                },
              ]
            }
          }
          "containers" = [
            {
              "args" = [
                "query",
                "--grpc-address=0.0.0.0:10901",
                "--http-address=0.0.0.0:9090",
                "--log.level=info",
                "--log.format=logfmt",
                "--query.replica-label=prometheus_replica",
                "--query.replica-label=rule_replica",
                "--store=dnssrv+_grpc._tcp.thanos-store.thanos.svc.cluster.local",
              ]
              "image" = "quay.io/thanos/thanos:v0.17.2"
              "livenessProbe" = {
                "failureThreshold" = 4
                "httpGet" = {
                  "path" = "/-/healthy"
                  "port" = 9090
                  "scheme" = "HTTP"
                }
                "periodSeconds" = 30
              }
              "name" = "thanos-query"
              "ports" = [
                {
                  "containerPort" = 10901
	  	  "protocol" = "TCP"
                  "name" = "grpc"
                },
                {
                  "containerPort" = 9090
	  	  "protocol" = "TCP"
                  "name" = "http"
                },
              ]
              "readinessProbe" = {
                "failureThreshold" = 20
                "httpGet" = {
                  "path" = "/-/ready"
                  "port" = 9090
                  "scheme" = "HTTP"
                }
                "periodSeconds" = 5
              }
              "resources" = {}
              "terminationMessagePolicy" = "FallbackToLogsOnError"
            },
          ]
          "terminationGracePeriodSeconds" = 120
        }
      }
    }
  }
}
