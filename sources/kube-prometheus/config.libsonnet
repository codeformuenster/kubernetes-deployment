{
  _config+:: {
    namespace: 'kube-prometheus',
    grafanaDomain: 'grafana.codeformuenster.org',
    retentionSize: '19GB',

    versions+: {
      blackboxExporter: 'v0.15.1',
      // kubeStateMetrics: 'v1.7.2',
      grafana: '6.4.0-beta1',
    },

    prometheus+:: {
      // additional namespaces to watch
      namespaces+: ['ingress-nginx', 'cert-manager', 'openebs'],
    },
  }
}