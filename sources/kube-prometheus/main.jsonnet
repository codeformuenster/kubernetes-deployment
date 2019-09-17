local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
local secret = k.core.v1.secret;
local pvc = k.core.v1.persistentVolumeClaim;

local kp =
  (import 'kube-prometheus/kube-prometheus.libsonnet') +
  (import 'kube-prometheus/kube-prometheus-kubeadm.libsonnet') +
  (import 'kube-prometheus/kube-prometheus-anti-affinity.libsonnet') +
  (import 'blackbox-exporter.libsonnet') +
  (import 'ingresses.libsonnet') +
  (import 'config.libsonnet') +
  {
    _config+:: {
      // namespace: 'kube-prometheus',
      // domain: 'grafana.codeformuenster.org',
      // retentionSize: '19G',

      imageRepos+: {
        blackboxExporter: 'prom/blackbox-exporter',
      },
      // versions+: {
      //   blackboxExporter: 'v0.15.1',
      //   // kubeStateMetrics: 'v1.7.2',
      //   grafana: 'v6.4.0-beta1',
      // },

      grafana+:: {
        config+: {
          sections+: {
            server+: {
              root_url: 'https://' + $._config.grafanaDomain + '/',
            },
          },
        },
      },
      // prometheus+:: {
      //   // additional namespaces to watch
      //   namespaces+: ['ingress-nginx', 'cert-manager', 'openebs'],
      // },
    },

    // grafana: {}, 

    prometheus+:: {
      prometheus+: {
        spec+: {
          // retention: '60d',
          // if exists ?
          retentionSize: $._config.retentionSize,
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
      additionalScrapeConfigs+:
        secret.new('additional-scrape-configs', {
          'prometheus-additional.yaml': std.base64(importstr 'prometheus-additional.yaml') }) +
        secret.mixin.metadata.withNamespace($._config.namespace),
    },
  };

[ kp.kubePrometheus[name] for name in std.objectFields(kp.kubePrometheus) ] +
[ kp.prometheusOperator[name] for name in std.objectFields(kp.prometheusOperator) ] +
[ kp.nodeExporter[name] for name in std.objectFields(kp.nodeExporter) ] +
[ kp.blackboxExporter[name] for name in std.objectFields(kp.blackboxExporter) ] +
[ kp.kubeStateMetrics[name] for name in std.objectFields(kp.kubeStateMetrics) ] +
[ kp.alertmanager[name] for name in std.objectFields(kp.alertmanager) ] +
[ kp.prometheus[name] for name in std.objectFields(kp.prometheus) ] +
[ kp.prometheusAdapter[name] for name in std.objectFields(kp.prometheusAdapter) ] +
[ kp.grafana[name] for name in std.objectFields(kp.grafana) ] +
[ kp.ingresses[name] for name in std.objectFields(kp.ingresses) ]