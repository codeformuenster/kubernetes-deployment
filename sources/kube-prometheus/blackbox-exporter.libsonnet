local k = import 'ksonnet/ksonnet.beta.4/k.libsonnet';

{
  _config+:: {
    namespace: 'default',

    versions+:: {
      blackboxExporter: 'v0.15.1',
    },

    imageRepos+:: {
      blackboxExporter: 'quay.io/prometheus/blackbox-exporter',
      // kubeRbacProxy: 'quay.io/coreos/kube-rbac-proxy',
    },

    blackboxExporter+:: {
      port: 9115,
    },
  },

  blackboxExporter+:: {

    deployment:
      // local deployment = k.apps.v1beta2.deployment;
      local deployment = k.apps.v1.deployment;
      local container = k.apps.v1.deployment.mixin.spec.template.spec.containersType;
      local volume = k.apps.v1.deployment.mixin.spec.template.spec.volumesType;
      local containerPort = container.portsType;
      local containerVolumeMount = container.volumeMountsType;
      local podSelector = deployment.mixin.spec.template.spec.selectorType;

      local podLabels = { app: 'blackbox-exporter' };

      local blackboxExporter =
        container.new('blackbox-exporter', $._config.imageRepos.blackboxExporter + ':' + $._config.versions.blackboxExporter) +
        container.withArgs([
          '--config.file=/etc/blackbox_exporter/config.yml',
        ]) +
        container.withPorts(containerPort.newNamed(9115, 'http'));
        //  +
        // container.mixin.resources.withRequests({ cpu: '10m', memory: '20Mi' }) +
        // container.mixin.resources.withLimits({ cpu: '20m', memory: '40Mi' });

      local c = [blackboxExporter];

      deployment.new('blackbox-exporter', 1, c, podLabels) +
      deployment.mixin.metadata.withNamespace($._config.namespace) +
      deployment.mixin.metadata.withLabels(podLabels) +
      deployment.mixin.spec.selector.withMatchLabels(podLabels) +
      // deployment.mixin.spec.template.spec.withNodeSelector({ 'beta.kubernetes.io/os': 'linux' }) +
      deployment.mixin.spec.template.spec.securityContext.withRunAsNonRoot(true) +
      deployment.mixin.spec.template.spec.securityContext.withRunAsUser(1000),
      // deployment.mixin.spec.template.spec.securityContext.readOnlyRootFilesystem(true),
      //  +
      // deployment.mixin.spec.template.spec.withServiceAccountName('kube-state-metrics'),


    service:
      local service = k.core.v1.service;
      local servicePort = k.core.v1.service.mixin.spec.portsType;

      local blackboxExporterPort = servicePort.newNamed('http', $._config.blackboxExporter.port, 'http');

      service.new('blackbox-exporter', $.blackboxExporter.deployment.spec.selector.matchLabels, blackboxExporterPort) +
      service.mixin.metadata.withNamespace($._config.namespace) +
      service.mixin.metadata.withLabels({ 'k8s-app': 'blackbox-exporter' })
      // + service.mixin.spec.withClusterIp('None'),
  },
}
