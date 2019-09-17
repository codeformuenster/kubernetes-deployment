local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';
// local k3 = import 'ksonnet/ksonnet.beta.3/k.libsonnet';

// local secret = k3.core.v1.secret;
local ingress = k.extensions.v1beta1.ingress;
local ingressTls = ingress.mixin.spec.tlsType;
local ingressRule = ingress.mixin.spec.rulesType;
local httpIngressPath = ingressRule.mixin.http.pathsType;
// local pvc = k3.core.v1.persistentVolumeClaim;

{
  // _config+:: {
  //   namespace: 'default',

  //   versions+:: {
  //     blackboxExporter: 'v0.14.0',
  //   },

  //   imageRepos+:: {
  //     blackboxExporter: 'quay.io/prometheus/blackbox-exporter',
  //     // kubeRbacProxy: 'quay.io/coreos/kube-rbac-proxy',
  //   },

  //   blackboxExporter+:: {
  //     port: 9115,
  //   },
  // },

  ingresses+:: {
    grafana:
      ingress.new() +
      ingress.mixin.metadata.withName('grafana') +
      ingress.mixin.metadata.withNamespace($._config.namespace) +
      ingress.mixin.spec.withRules(
        ingressRule.new() +
        ingressRule.withHost($._config.grafanaDomain) +
        ingressRule.mixin.http.withPaths(
          httpIngressPath.new() +
          httpIngressPath.mixin.backend.withServiceName('grafana') +
          httpIngressPath.mixin.backend.withServicePort('http')
        ),
      ) +
      ingress.mixin.spec.withTls(
        ingressTls.new() +
        ingressTls.withHosts($._config.grafanaDomain) +
        ingressTls.withSecretName('grafana-tls')
      ),

    grafana_certificate: { 
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
        commonName: $._config.grafanaDomain,
        issuerRef: {
          kind: 'ClusterIssuer',
          name: 'letsencrypt',
        },
      },
    },
  },
}
