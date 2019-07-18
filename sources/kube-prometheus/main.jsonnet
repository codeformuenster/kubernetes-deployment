// FIXME switch to ksonnet.beta.4
local k = import 'ksonnet/ksonnet.beta.3/k.libsonnet';
local secret = k.core.v1.secret;
local ingress = k.extensions.v1beta1.ingress;
local ingressTls = ingress.mixin.spec.tlsType;
local ingressRule = ingress.mixin.spec.rulesType;
local httpIngressPath = ingressRule.mixin.http.pathsType;
local pvc = k.core.v1.persistentVolumeClaim;

local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') +
  (import 'kube-prometheus/kube-prometheus-kubeadm.libsonnet') +
  // Uncomment the following imports to enable its patches
  (import 'kube-prometheus/kube-prometheus-anti-affinity.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-managed-cluster.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-node-ports.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-static-etcd.libsonnet') +
  // (import 'kube-prometheus/kube-prometheus-thanos.libsonnet') +
  {
    _config+:: {
      namespace: 'kube-prometheus',
      domain: 'grafana.codeformuenster.org',

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
        namespaces+: ['ingress-nginx', 'cert-manager'],
      },
    },
    prometheus+:: {
      prometheus+: {
        spec+: {
          retention: '60d',
          // additionalScrapeConfigs: {
          //   name: 'additional-scrape-configs',
          //   key: 'prometheus-additional.yaml',
          // },
          storage: {
            volumeClaimTemplate: 
              pvc.new() +
              pvc.mixin.spec.withAccessModes('ReadWriteOnce') +
              pvc.mixin.spec.resources.withRequests({ storage: '20Gi' }),
              // pvc.mixin.spec.withStorageClassName('ssd'),
          },
        },
      },
    },
    // FIXME
    // Create the additional-scrape-configs here
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
    certManager: {
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

{ ['00namespace-' + name]: kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) } +
{ ['0prometheus-operator-' + name]: kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) } +
{ ['node-exporter-' + name]: kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) } +
{ ['kube-state-metrics-' + name]: kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) } +
{ ['alertmanager-' + name]: kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) } +
{ ['prometheus-' + name]: kp.prometheus[name] for name in std.objectFields(kp.prometheus) } +
{ ['prometheus-adapter-' + name]: kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) } +
{ ['grafana-' + name]: kp.grafana[name] for name in std.objectFields(kp.grafana) } +
{ [name + '-ingress']: kp.ingress[name] for name in std.objectFields(kp.ingress) } +
{ [name + '-certificate']: kp.certManager[name] for name in std.objectFields(kp.certManager) }