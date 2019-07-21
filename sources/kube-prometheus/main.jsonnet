// FIXME switch to ksonnet.beta.4
local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
local k3 = import 'ksonnet/ksonnet.beta.3/k.libsonnet';
local secret = k3.core.v1.secret;
local ingress = k3.extensions.v1beta1.ingress;
local ingressTls = ingress.mixin.spec.tlsType;
local ingressRule = ingress.mixin.spec.rulesType;
local httpIngressPath = ingressRule.mixin.http.pathsType;
local pvc = k3.core.v1.persistentVolumeClaim;
// local deployment = k.apps.v1.deployment;

// local container = deployment.mixin.spec.template.spec.containersType;
// local volume = deployment.mixin.spec.template.spec.volumesType;
// local containerPort = container.portsType;
// local containerVolumeMount = container.volumeMountsType;
// local podSelector = deployment.mixin.spec.template.spec.selectorType;


local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') +
  (import 'kube-prometheus/kube-prometheus-kubeadm.libsonnet') +
  (import 'kube-prometheus/kube-prometheus-anti-affinity.libsonnet') +
  {
    _config+:: {
      namespace: 'kube-prometheus',
      domain: 'grafana.codeformuenster.org',

      imageRepos+: {
        blackboxExporter: 'prom/blackbox-exporter',
      },
      versions+: {
        blackboxExporter: 'v0.14.0',
      },

      grafana+:: {
        config+: {
          sections+: {
            server+: {
              root_url: 'https://' + $._config.domain + '/',
            },
          },
        },
      },
      prometheus+:: {
        // additional namespaces to watch
        namespaces+: ['ingress-nginx', 'cert-manager', 'openebs'],
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          retention: '60d',
          additionalScrapeConfigs: {
            name: 'additional-scrape-configs',
            key: 'prometheus-additional.yaml',
          },
          storage: {
            volumeClaimTemplate: 
              pvc.new() +
              pvc.mixin.spec.withAccessModes('ReadWriteOnce') +
              pvc.mixin.spec.resources.withRequests({ storage: '20Gi' }),
          },
        },
      },
    },
    additionalScrapeConfigs: {
      'additional-scrape-configs':
        secret.new('additional-scrape-configs', { 'prometheus-additional.yaml': std.base64(importstr 'prometheus-additional.yaml') }) +
        secret.mixin.metadata.withNamespace($._config.namespace),
      // https://github.com/helm/charts/blob/master/stable/prometheus-blackbox-exporter/templates/deployment.yaml#L50
      'blackbox-exporter': { 
          apiVersion: 'apps/v1',
          kind: 'Deployment',
          metadata: {
            name: 'blackbox-exporter',
            namespace: $._config.namespace,
            labels: {
              'app.kubernetes.io/name': 'blackbox-exporter',
              'app.kubernetes.io/part-of': 'kube-prometheus',
              // ^ FIXME maybe 'prometheus-kubernetes'?
            },
          },
          spec: {
            replicas: 2,
            selector: {
              matchLabels: {
                // FIXME use something like $.self?
                'app.kubernetes.io/name': 'blackbox-exporter',
                'app.kubernetes.io/part-of': 'kube-prometheus',
              },
            },
            strategy: {
              rollingUpdate: {
                maxSurge: 1,
                maxUnavailable: 0,
              },
              type: 'RollingUpdate',
            },
            template: {
              metadata: {
                labels: {
                  // FIXME use something like $.self?
                  'app.kubernetes.io/name': 'blackbox-exporter',
                  'app.kubernetes.io/part-of': 'kube-prometheus',
                },
              },
              // restartPolicy: {{ .Values.restartPolicy }}
              spec: {
                containers: [
                  {
                    name: 'blackbox-exporter',
                    image: $._config.imageRepos.blackboxExporter + ':' + $._config.versions.blackboxExporter,
                    // imagePullPolicy: {{ .Values.image.pullPolicy }}
                    securityContext: {
                      runAsNonRoot: true,
                      runAsUser: 1000,
                      readOnlyRootFilesystem: true,
                    },
                    args: ['--config.file=/etc/blackbox_exporter/config.yml'],
                    ports: [
                      {
                        containerPort: 9115,
                        name: 'http',
                      }
                    ],
                  },
                ],
              },
            },
          },
        },
      'blackbox-exporter-service': {
        apiVersion: 'v1',
        kind: 'Service',
        metadata: {
          name: 'blackbox-exporter',
          namespace: $._config.namespace,
          labels: {
            // FIXME use something like $.self or common labels?
            'app.kubernetes.io/name': 'blackbox-exporter',
            'app.kubernetes.io/part-of': 'kube-prometheus',
          },
        },
        spec: {
          // type: {{ .Values.service.type }}
          ports: [
            {
              name: 'http',
              port: 9115,
              protocol: 'TCP',
            },
          ],
          selector: {
            'app.kubernetes.io/name': 'blackbox-exporter',
            'app.kubernetes.io/part-of': 'kube-prometheus',
          },
        },
      },
    },
    ingress+:: {
      grafana:
        ingress.new() +
        ingress.mixin.metadata.withName('grafana') +
        ingress.mixin.metadata.withNamespace($._config.namespace) +
        ingress.mixin.spec.withRules(
          ingressRule.new() +
          ingressRule.withHost($._config.domain) +
          ingressRule.mixin.http.withPaths(
            httpIngressPath.new() +
            httpIngressPath.mixin.backend.withServiceName('grafana') +
            httpIngressPath.mixin.backend.withServicePort('http')
          ),
        ) +
        ingress.mixin.spec.withTls(
          ingressTls.new() +
          ingressTls.withHosts($._config.domain) +
          ingressTls.withSecretName('grafana-tls')
        ),
    },
    certificate: {
      grafana: { 
        apiVersion: 'certmanager.k8s.io/v1alpha1',
        kind: 'Certificate',
        metadata: {
          name: 'grafana-tls',
          namespace: $._config.namespace,
        },
          // labels:
          //   app.kubernetes.io/name: grafana
          //   app.kubernetes.io/component: webserver
        spec: {
          secretName: 'grafana-tls',
          commonName: $._config.domain,
          issuerRef: {
            kind: 'ClusterIssuer',
            name: 'letsencrypt',
          },
        },
      },
    },
  };

// { ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
// { ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
// { ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
// { ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
// { ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
// { ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
// { ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
// { ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
// { [name + '-ingress']: kp.ingress[name] for name in std.objectFields(kp.ingress) } +
// { [name + '-certificate']: kp.certManager[name] for name in std.objectFields(kp.certManager) }

[ kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) ] +
[ kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) ] +
[ kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) ] +
[ kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) ] +
[ kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) ] +
[ kp.prometheus[name] for name in std.objectFields(kp.prometheus) ] +
[ kp.additionalScrapeConfigs[name] for name in std.objectFields(kp.additionalScrapeConfigs) ] +
[ kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) ] +
[ kp.grafana[name] for name in std.objectFields(kp.grafana) ] +
[ kp.ingress[name] for name in std.objectFields(kp.ingress) ] +
[ kp.certificate[name] for name in std.objectFields(kp.certificate) ]