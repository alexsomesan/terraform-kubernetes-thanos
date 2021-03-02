resource "kubernetes_manifest" "statefulset_thanos_store" {
  provider = kubernetes-alpha

  manifest = {
    "apiVersion" = "apps/v1"
    "kind" = "StatefulSet"
    "metadata" = {
      "labels" = {
        "app.kubernetes.io/component" = "object-store-gateway"
        "app.kubernetes.io/instance" = "thanos-store"
        "app.kubernetes.io/name" = "thanos-store"
        "app.kubernetes.io/version" = "v0.17.2"
      }
      "name" = "thanos-store"
      "namespace" = "thanos"
    }
    "spec" = {
      "replicas" = 1
      "selector" = {
        "matchLabels" = {
          "app.kubernetes.io/component" = "object-store-gateway"
          "app.kubernetes.io/instance" = "thanos-store"
          "app.kubernetes.io/name" = "thanos-store"
        }
      }
      "serviceName" = "thanos-store"
      "template" = {
        "metadata" = {
          "labels" = {
            "app.kubernetes.io/component" = "object-store-gateway"
            "app.kubernetes.io/instance" = "thanos-store"
            "app.kubernetes.io/name" = "thanos-store"
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
                            "thanos-store",
                          ]
                        },
                        {
                          "key" = "app.kubernetes.io/instance"
                          "operator" = "In"
                          "values" = [
                            "thanos-store",
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
                "store",
                "--log.level=info",
                "--log.format=logfmt",
                "--data-dir=/var/thanos/store",
                "--grpc-address=0.0.0.0:10901",
                "--http-address=0.0.0.0:10902",
                "--objstore.config=$(OBJSTORE_CONFIG)",
                "--ignore-deletion-marks-delay=24h",
              ]
              "env" = [
                {
                  "name" = "OBJSTORE_CONFIG"
                  "valueFrom" = {
                    "secretKeyRef" = {
                      "key" = "thanos.yaml"
                      "name" = "thanos-objectstorage"
                    }
                  }
                },
              ]
              "image" = "quay.io/thanos/thanos:v0.17.2"
              "livenessProbe" = {
                "failureThreshold" = 8
                "httpGet" = {
                  "path" = "/-/healthy"
                  "port" = 10902
                  "scheme" = "HTTP"
                }
                "periodSeconds" = 30
              }
              "name" = "thanos-store"
              "ports" = [
                {
                  "containerPort" = 10901
	  	  "protocol" = "TCP"
                  "name" = "grpc"
                },
                {
                  "containerPort" = 10902
	  	  "protocol" = "TCP"
                  "name" = "http"
                },
              ]
              "readinessProbe" = {
                "failureThreshold" = 20
                "httpGet" = {
                  "path" = "/-/ready"
                  "port" = 10902
                  "scheme" = "HTTP"
                }
                "periodSeconds" = 5
              }
              "resources" = {}
              "terminationMessagePolicy" = "FallbackToLogsOnError"
              "volumeMounts" = [
                {
                  "mountPath" = "/var/thanos/store"
                  "name" = "data"
                  "readOnly" = false
                },
              ]
            },
          ]
          "terminationGracePeriodSeconds" = 120
          "volumes" = []
        }
      }
      "volumeClaimTemplates" = [
        {
          "metadata" = {
            "labels" = {
              "app.kubernetes.io/component" = "object-store-gateway"
              "app.kubernetes.io/instance" = "thanos-store"
              "app.kubernetes.io/name" = "thanos-store"
            }
            "name" = "data"
          }
          "spec" = {
            "accessModes" = [
              "ReadWriteOnce",
            ]
            "resources" = {
              "requests" = {
                "storage" = "10Gi"
              }
            }
          }
        },
      ]
    }
  }
}
