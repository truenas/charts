require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Webservice Deployments configuration' do
  def item_key(kind, name)
    "#{kind}/test-webservice-#{name}"
  end

  def env_value(name, value)
    { 'name' => name, 'value' => value.to_s }
  end

  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
    ))
  end

  context 'When customer provides additional labels' do
    let(:values) do
      YAML.safe_load(%(
        global:
          appConfig:
            smartcard:
              enabled: true
          common:
            labels:
              global: true
              foo: global
          pod:
            labels:
              global_pod: true
              foo: global_pod
          service:
            labels:
              global_service: true
              foo: global_service
        gitlab:
          webservice:
            common:
              labels:
                global: webservice
                ws_common: true
                foo: webservice-common
                webservice: webservice
            networkpolicy:
              enabled: true
            podLabels:
              foo: webservice_pod
              ws_pod: true
              global: pod
            serviceAccount:
              create: true
              enabled: true
            serviceLabels:
              foo: webservice_service
              ws_service: true
              global: service
      )).deep_merge(default_values)
    end

    let(:web_deployment) do
      YAML.safe_load(%(
        gitlab:
          webservice:
            deployments:
              web:
                ingress:
                  path: /
                common:
                  labels:
                    web_common: true
                    foo: web-common
                pod:
                  labels:
                    web_pod: true
                    foo: web-pod
      )).deep_merge(values)
    end

    it 'Populates the additional labels in the expected manner on the default deployment' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(t.labels('ConfigMap/test-webservice')).to include('global' => 'webservice')
      expect(t.labels('ConfigMap/test-webservice')).to include('webservice' => 'webservice')
      expect(t.labels('ConfigMap/test-webservice')).not_to include('global' => 'global')

      expect(t.labels('Deployment/test-webservice-default')).to include('foo' => 'webservice-common')
      expect(t.labels('Deployment/test-webservice-default')).to include('global' => 'webservice')
      expect(t.labels('Deployment/test-webservice-default')).not_to include('global' => 'global')

      expect(t.template_labels('Deployment/test-webservice-default')).to include('global' => 'webservice')
      expect(t.template_labels('Deployment/test-webservice-default')).to include('global_pod' => 'true')
      expect(t.template_labels('Deployment/test-webservice-default')).to include('ws_pod' => 'true')

      expect(t.labels('Ingress/test-webservice-default')).to include('global' => 'webservice')
      expect(t.labels('Ingress/test-webservice-default-smartcard')).to include('global' => 'webservice')

      expect(t.labels('Service/test-webservice-default')).to include('global' => 'webservice')
      expect(t.labels('Service/test-webservice-default')).to include('global_service' => 'true')
      expect(t.labels('Service/test-webservice-default')).to include('ws_service' => 'true')
      expect(t.labels('Service/test-webservice-default')).to include('webservice' => 'webservice')
      expect(t.labels('Service/test-webservice-default')).not_to include('global' => 'global')

      expect(t.labels('ServiceAccount/test-webservice')).to include('global' => 'webservice')

      expect(t.labels('HorizontalPodAutoscaler/test-webservice-default')).to include('global' => 'webservice')

      expect(t.labels('NetworkPolicy/test-webservice-v1')).to include('global' => 'webservice')

      expect(t.labels('PodDisruptionBudget/test-webservice-default')).to include('global' => 'webservice')
    end

    it 'Populates the additional labels on on all objects per deployment' do
      t = HelmTemplate.new(web_deployment)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

      expect(t.labels('Deployment/test-webservice-web')).to include('foo' => 'web-common')
      expect(t.labels('Deployment/test-webservice-web')).to include('web_common' => 'true')
      expect(t.labels('Deployment/test-webservice-web')).to include('ws_common' => 'true')
      expect(t.labels('Deployment/test-webservice-web')).to include('global' => 'webservice')
      expect(t.labels('Deployment/test-webservice-web')).to include('webservice' => 'webservice')

      expect(t.labels('Deployment/test-webservice-web')).not_to include('foo' => 'webservice-common')
      expect(t.labels('Deployment/test-webservice-web')).not_to include('foo' => 'global-pod')
      expect(t.labels('Deployment/test-webservice-web')).not_to include('web_pod' => 'true')
      expect(t.labels('Deployment/test-webservice-web')).not_to include('foo' => 'web-pod')
      expect(t.labels('Deployment/test-webservice-web')).not_to include('foo' => 'webservice_service')
      expect(t.labels('Deployment/test-webservice-web')).not_to include('ws_service' => 'true')
      expect(t.labels('Deployment/test-webservice-web')).not_to include('ws_pod' => 'true')
      expect(t.labels('Deployment/test-webservice-web')).not_to include('global' => 'service')
      expect(t.labels('Deployment/test-webservice-web')).not_to include('global' => 'pod')
      expect(t.labels('Deployment/test-webservice-web')).not_to include('global_pod' => 'true')
      expect(t.labels('Deployment/test-webservice-web')).not_to include('global_service' => 'true')
      expect(t.labels('Deployment/test-webservice-web')).not_to include('foo' => 'global_service')

      expect(t.template_labels('Deployment/test-webservice-web')).to include('foo' => 'web-pod')
      expect(t.template_labels('Deployment/test-webservice-web')).to include('web_pod' => 'true')
      expect(t.template_labels('Deployment/test-webservice-web')).to include('web_common' => 'true')
      expect(t.template_labels('Deployment/test-webservice-web')).to include('ws_common' => 'true')
      expect(t.template_labels('Deployment/test-webservice-web')).to include('global' => 'webservice')
      expect(t.template_labels('Deployment/test-webservice-web')).to include('webservice' => 'webservice')
      expect(t.template_labels('Deployment/test-webservice-web')).not_to include('foo' => 'webservice_pod')

      expect(t.labels('Ingress/test-webservice-web')).to include('foo' => 'web-common')
      expect(t.labels('Ingress/test-webservice-web')).to include('web_common' => 'true')
      expect(t.labels('Ingress/test-webservice-web')).to include('ws_common' => 'true')
      expect(t.labels('Ingress/test-webservice-web')).to include('global' => 'webservice')
      expect(t.labels('Ingress/test-webservice-web')).to include('webservice' => 'webservice')

      expect(t.labels('Service/test-webservice-web')).to include('foo' => 'web-common')
      expect(t.labels('Service/test-webservice-web')).to include('ws_service' => 'true')
      expect(t.labels('Service/test-webservice-web')).to include('web_common' => 'true')
      expect(t.labels('Service/test-webservice-web')).to include('ws_common' => 'true')
      expect(t.labels('Service/test-webservice-web')).to include('global' => 'webservice')
      expect(t.labels('Service/test-webservice-web')).to include('webservice' => 'webservice')
      expect(t.labels('Service/test-webservice-web')).not_to include('foo' => 'global-pod')
      expect(t.labels('Service/test-webservice-web')).not_to include('foo' => 'webservice_service')
      expect(t.labels('Service/test-webservice-web')).not_to include('global' => 'service')

      expect(t.labels('HorizontalPodAutoscaler/test-webservice-web')).to include('foo' => 'web-common')

      expect(t.labels('PodDisruptionBudget/test-webservice-web')).to include('foo' => 'web-common')
    end
  end

  context 'gitlab.webservice.deployments not set' do
    let(:chart_defaults) { HelmTemplate.new(default_values) }

    it 'templates successfully' do
      expect(chart_defaults.exit_code).to eq(0)
    end

    it 'creates only Deployment/test-webservice-default' do
      expect(chart_defaults.dig(item_key('Deployment', 'default'))).to be_truthy
      expect(chart_defaults.dig(item_key('Deployment', 'other'))).to be_falsey
    end

    it 'creates a default set of volume mounts' do
      volumes = chart_defaults.dig('Deployment/test-webservice-default', 'spec', 'template', 'spec', 'volumes')

      expect(volumes).to include({ 'name' => 'shared-tmp', 'emptyDir' => {} })
      expect(volumes).to include({ 'name' => 'shared-upload-directory', 'emptyDir' => {} })
    end
  end

  context 'gitlab.webservice.deployments has entries' do
    let(:deployments_values) do
      YAML.safe_load(%(
      gitlab:
        webservice:
          deployments:
            default:
              ingress:
                path: /
            api:
              ingress:
                path: /api
            internal:
               ingress:
                  path:
      )).deep_merge(default_values)
    end

    let(:chart_deployments) { HelmTemplate.new(deployments_values) }

    it 'creates resources expected for 3 entries, one without an Ingress' do
      expect(chart_deployments.exit_code).to eq(0)

      items = chart_deployments.resources_by_kind('Deployment').select { |key, _| key.start_with? "Deployment/test-webservice-" }
      expect(items.length).to eq(3)
      expect(items.dig(item_key('Deployment', 'default'))).to be_truthy
      expect(items.dig(item_key('Deployment', 'api'))).to be_truthy
      expect(items.dig(item_key('Deployment', 'internal'))).to be_truthy

      items = chart_deployments.resources_by_kind('PodDisruptionBudget').select { |key, _| key.start_with? "PodDisruptionBudget/test-webservice-" }
      expect(items.length).to eq(3)
      expect(items.dig(item_key('PodDisruptionBudget', 'default'))).to be_truthy
      expect(items.dig(item_key('PodDisruptionBudget', 'api'))).to be_truthy
      expect(items.dig(item_key('PodDisruptionBudget', 'internal'))).to be_truthy

      items = chart_deployments.resources_by_kind('HorizontalPodAutoscaler').select { |key, _| key.start_with? "HorizontalPodAutoscaler/test-webservice-" }
      expect(items.length).to eq(3)
      expect(items.dig(item_key('HorizontalPodAutoscaler', 'default'))).to be_truthy
      expect(items.dig(item_key('HorizontalPodAutoscaler', 'api'))).to be_truthy
      expect(items.dig(item_key('HorizontalPodAutoscaler', 'internal'))).to be_truthy

      items = chart_deployments.resources_by_kind('Service').select { |key, _| key.start_with? "Service/test-webservice-" }
      expect(items.length).to eq(3)
      expect(items.dig(item_key('Service', 'default'))).to be_truthy
      expect(items.dig(item_key('Service', 'api'))).to be_truthy
      expect(items.dig(item_key('Service', 'internal'))).to be_truthy

      items = chart_deployments.resources_by_kind('Ingress').select { |key, _| key.start_with? "Ingress/test-webservice-" }
      expect(items.length).to eq(2)
      expect(items.dig(item_key('Ingress', 'default'))).to be_truthy
      expect(items.dig(item_key('Ingress', 'api'))).to be_truthy

      items = chart_deployments.resources_by_kind('ConfigMap').select { |key, _| key.start_with? "ConfigMap/test-webservice" }
      expect(items.length).to eq(2)
      expect(items.dig('ConfigMap/test-webservice')).to be_truthy
      expect(items.dig(item_key('ConfigMap', 'tests'))).to be_truthy
    end
  end

  context 'deployments datamodel' do
    let(:test_values) do
      YAML.safe_load(%(
      gitlab:
        webservice:
          deployments:
            test:
              ingress:
                path: /
      )).deep_merge(default_values)
    end

    let(:datamodel) { HelmTemplate.new(test_values) }

    context 'when no Ingress has "path: /"' do
      let(:test_values) do
        YAML.safe_load(%(
        gitlab:
          webservice:
            deployments:
              test:
                ingress:
                  path:
        )).deep_merge(default_values)
      end

      it 'template fails' do
        expect(datamodel.exit_code).not_to eq(0)
      end
    end

    context 'value inheritance and merging' do
      let(:test_values) do
        YAML.safe_load(%(
        global:
          extraEnv:
            GLOBAL: present
        gitlab:
          webservice:
            # "base" configuration
            minReplicas: 1
            maxReplicas: 2
            puma:
              disableWorkerKiller: true
            pdb:
              maxUnavailable: 0
            deployment:
              annotations:
                some: "thing"
            serviceLabels:
              some: "thing"
            podLabels:
              some: "thing"
            ingress:
              annotations:
                some: "thing"
            nodeSelector:
              workload: "webservice"
            tolerations:
              - key: "node_label"
                operator: "Equal"
                value: "true"
                effect: "NoSchedule"
            extraEnv:
              CHART: "present"
            # individual configurations
            deployments:
              a:
                ingress:
                  path: /
                deployment:
                  annotations:
                    thing: "one"
                nodeSelector: # disable nodeSelector
                tolerations: null # disable tolerations
                sshHostKeys:
                  mount: true
              b:
                puma:
                  threads:
                    min: 3
                hpa:
                  minReplicas: 10
                  maxReplicas: 20
                nodeSelector: # replace nodeSelector
                  section: "b"
                tolerations: # specify tolerations
                  - key: "node_label"
                    operator: "Equal"
                    value: "true"
                    effect: "NoExecute"
                extraEnv:
                  DEPLOYMENT: "b"
                sshHostKeys:
                  mount: true
                  mountName: ssh-host-keys-b
                  types:
                  - dsa
              c:
                puma:
                  threads:
                    min: 2
                    max: 8
                  workerMaxMemory: 2048
                  disableWorkerKiller: false
                extraEnv:
                  DEPLOYMENT: "c"
                  CHART: "overridden"
        )).deep_merge(default_values)
      end

      it 'templates successfully' do
        expect(datamodel.exit_code).to eq(0)
      end

      context 'Puma settings' do
        it 'override only those set (int, string, bool)' do
          env_1 = datamodel.env(item_key('Deployment', 'a'), 'webservice')
          env_2 = datamodel.env(item_key('Deployment', 'b'), 'webservice')
          env_3 = datamodel.env(item_key('Deployment', 'c'), 'webservice')

          expect(env_1).to include(env_value('PUMA_THREADS_MIN', 4))
          expect(env_2).to include(env_value('PUMA_THREADS_MIN', 3))
          expect(env_3).to include(env_value('PUMA_THREADS_MIN', 2))

          expect(env_1).to include(env_value('PUMA_THREADS_MAX', 4))
          expect(env_2).to include(env_value('PUMA_THREADS_MAX', 4))
          expect(env_3).to include(env_value('PUMA_THREADS_MAX', 8))

          expect(env_1).to include(env_value('PUMA_WORKER_MAX_MEMORY', 1024))
          expect(env_2).to include(env_value('PUMA_WORKER_MAX_MEMORY', 1024))
          expect(env_3).to include(env_value('PUMA_WORKER_MAX_MEMORY', 2048))

          expect(env_1).to include(env_value('DISABLE_PUMA_WORKER_KILLER', true))
          expect(env_2).to include(env_value('DISABLE_PUMA_WORKER_KILLER', true))
          expect(env_3).to include(env_value('DISABLE_PUMA_WORKER_KILLER', false))
        end
      end

      context 'extraEnv settings (map)' do
        # deployment(X)/spec/template/spec/nodeSelector
        it 'inherits when not present' do
          env_1 = datamodel.env(item_key('Deployment', 'a'), 'webservice')
          expect(env_1).to include(env_value('GLOBAL', 'present'))
          expect(env_1).to include(env_value('CHART', 'present'))
          expect(env_1).not_to include(env_value('DEPLOYMENT', 'a'))
        end

        it 'merges when present' do
          env_1 = datamodel.env(item_key('Deployment', 'b'), 'webservice')
          expect(env_1).to include(env_value('GLOBAL', 'present'))
          expect(env_1).to include(env_value('CHART', 'present'))
          expect(env_1).to include(env_value('DEPLOYMENT', 'b'))
        end

        it 'override when present' do
          env_1 = datamodel.env(item_key('Deployment', 'c'), 'webservice')
          expect(env_1).to include(env_value('GLOBAL', 'present'))
          expect(env_1).to include(env_value('CHART', 'overridden'))
          expect(env_1).to include(env_value('DEPLOYMENT', 'c'))
        end
      end

      context 'nodeSelector settings (map)' do
        # deployment(X)/spec/template/spec/nodeSelector
        it 'removes when nil' do
          pod_template_spec = datamodel.dig(item_key('Deployment', 'a'), 'spec', 'template', 'spec')
          expect(pod_template_spec['nodeSelector']).to be_falsey
        end

        it 'merges when present' do
          pod_template_spec = datamodel.dig(item_key('Deployment', 'b'), 'spec', 'template', 'spec')
          expect(pod_template_spec['nodeSelector']).to be_truthy
          expect(pod_template_spec['nodeSelector']).to eql({ 'section' => 'b', 'workload' => 'webservice' })
        end

        it 'inherits when not present' do
          expect(datamodel.exit_code).to eq(0)
          pod_template_spec = datamodel.dig(item_key('Deployment', 'c'), 'spec', 'template', 'spec')

          expect(pod_template_spec['nodeSelector']).to be_truthy
          expect(pod_template_spec['nodeSelector']).to eql({ 'workload' => 'webservice' })
        end
      end

      context 'toleration settings (array)' do
        # deployment(X)/spec/template/spec/tolerations
        it 'removes when nil' do
          pod_template_spec = datamodel.dig(item_key('Deployment', 'a'), 'spec', 'template', 'spec')
          expect(pod_template_spec['tolerations']).to be_falsey
        end

        it 'overwrites when present' do
          pod_template_spec = datamodel.dig(item_key('Deployment', 'b'), 'spec', 'template', 'spec')
          expect(pod_template_spec['tolerations']).to be_truthy
          expect(pod_template_spec['tolerations'][0]['effect']).to eql("NoExecute")
        end

        it 'inherits when not present' do
          expect(datamodel.exit_code).to eq(0)
          pod_template_spec = datamodel.dig(item_key('Deployment', 'c'), 'spec', 'template', 'spec')

          expect(pod_template_spec['tolerations']).to be_truthy
          expect(pod_template_spec['tolerations'][0]['effect']).to eql("NoSchedule")
        end
      end

      context 'sshHostKeys settings (map)' do
        it 'adds the SSH host keys volume' do
          volume_a = datamodel.find_volume(item_key('Deployment', 'a'), 'ssh-host-keys')
          volume_b = datamodel.find_volume(item_key('Deployment', 'b'), 'ssh-host-keys-b')
          volume_c = datamodel.find_volume(item_key('Deployment', 'c'), 'ssh-host-keys')

          expect(volume_a).not_to be_nil
          expect(volume_b).not_to be_nil
          expect(volume_c).to be_nil
        end

        it 'inherits when not present' do
          # mountName already covered in a previous case
          volume_a = datamodel.find_volume(item_key('Deployment', 'a'), 'ssh-host-keys')
          items_a = volume_a.dig('secret', 'items')

          expect(items_a.length).to eq(4)
        end

        it 'overrides when set' do
          # mountName override already covered in previous case
          volume_b = datamodel.find_volume(item_key('Deployment', 'b'), 'ssh-host-keys-b')

          items_b = volume_b.dig('secret', 'items')

          expect(items_b.length).to eq(1)
        end

        it 'mounts the public keys for the expected deployments at the expected path' do
          vm_a = datamodel.find_volume_mount(item_key('Deployment', 'a'), 'webservice', 'ssh-host-keys')
          vm_b = datamodel.find_volume_mount(item_key('Deployment', 'b'), 'webservice', 'ssh-host-keys-b')
          vm_c = datamodel.find_volume_mount(item_key('Deployment', 'c'), 'webservice', 'ssh-host-keys')

          expect(vm_a).not_to be_nil
          expect(vm_b).not_to be_nil
          expect(vm_c).to be_nil

          # the expected path is hardcoded
          # https://gitlab.com/gitlab-org/gitlab/-/blob/81826be88622659dfa20f4ce2359660a9e51e4da/app/models/instance_configuration.rb#L7
          expect(vm_a['mountPath']).to eq('/etc/ssh')
          expect(vm_b['mountPath']).to eq('/etc/ssh')
        end
      end
    end

    context 'local ingress provider annotations' do
      let(:deployments_values) do
        YAML.safe_load(%(
          gitlab:
            webservice:
              deployments:
                default:
                  ingress:
                    path: /
                second:
                  ingress:
                    path: /second
                    provider: second-provider
        )).deep_merge(default_values)
      end

      it 'properly sets the ingress providers' do
        t = HelmTemplate.new(deployments_values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        expect(t.annotations('Ingress/test-webservice-default')).to include('kubernetes.io/ingress.provider' => 'nginx')
        expect(t.annotations('Ingress/test-webservice-second')).to include('kubernetes.io/ingress.provider' => 'second-provider')
      end
    end

    context 'global ingress provider annotations' do
      let(:deployments_values) do
        YAML.safe_load(%(
          global:
            ingress:
              provider: global-provider
          gitlab:
            webservice:
              deployments:
                default:
                  ingress:
                    path: /
                second:
                  ingress:
                    path: /second
                    provider: second-provider
        )).deep_merge(default_values)
      end

      it 'properly sets the ingress providers' do
        t = HelmTemplate.new(deployments_values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        expect(t.annotations('Ingress/test-webservice-default')).to include('kubernetes.io/ingress.provider' => 'global-provider')
        expect(t.annotations('Ingress/test-webservice-second')).to include('kubernetes.io/ingress.provider' => 'second-provider')
      end
    end
  end

  context 'shutdown.blackoutSeconds' do
    let(:chart_values) do
      YAML.safe_load(%(
        gitlab:
          webservice:
            shutdown:
              blackoutSeconds: 20
            # individual configurations
            deployments:
              a:
                ingress:
                  path: /
              b:
                ingress:
                  path: /b
              c:
                ingress:
                  path: /c
        )).deep_merge(default_values)
    end

    let(:deployment_values) do
      YAML.safe_load(%(
        gitlab:
          webservice:
            # individual configurations
            deployments:
              a:
                shutdown:
                  blackoutSeconds: 120
              b:
                shutdown:
                  blackoutSeconds: 0
        )).deep_merge(chart_values)
    end

    it 'setting chart wide applys to all' do
      t = HelmTemplate.new(chart_values)

      expect(t.exit_code).to eq(0)
      expect(t.env('Deployment/test-webservice-a', 'webservice')).to include(env_value('SHUTDOWN_BLACKOUT_SECONDS', 20))
      expect(t.env('Deployment/test-webservice-b', 'webservice')).to include(env_value('SHUTDOWN_BLACKOUT_SECONDS', 20))
      expect(t.env('Deployment/test-webservice-c', 'webservice')).to include(env_value('SHUTDOWN_BLACKOUT_SECONDS', 20))
    end

    it 'setting deployment overrides chart when present' do
      t = HelmTemplate.new(deployment_values)

      expect(t.exit_code).to eq(0)
      expect(t.env('Deployment/test-webservice-a', 'webservice')).to include(env_value('SHUTDOWN_BLACKOUT_SECONDS', 120))
      expect(t.env('Deployment/test-webservice-b', 'webservice')).to include(env_value('SHUTDOWN_BLACKOUT_SECONDS', 0))
      expect(t.env('Deployment/test-webservice-c', 'webservice')).to include(env_value('SHUTDOWN_BLACKOUT_SECONDS', 20))
    end
  end

  context 'when workhorse keywatcher flag is enabled' do
    let(:deployments_values) do
      YAML.safe_load(%(
        gitlab:
          webservice:
            deployments:
              default:
                workhorse:
                  keywatcher: false
                ingress:
                  path: /
              api:
                ingress:
                  path: /api
              git:
                workhorse:
                  keywatcher: false
                ingress:
                  path:
      )).deep_merge(default_values)
    end

    it 'configmap is generated' do
      t = HelmTemplate.new(deployments_values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

      # Read ConfigMaps from the rendered template
      configmaps = t.resources_by_kind('ConfigMap')
      workhorse_config = {}
      ['default', 'api', 'git'].each do |container|
        workhorse_config[container] = configmaps.fetch("ConfigMap/test-workhorse-#{container}").fetch("data").fetch("workhorse-config.toml.tpl")
      end

      expect(workhorse_config['default']).not_to include("[redis]")
      expect(workhorse_config['api']).to include("[redis]")
      expect(workhorse_config['git']).not_to include("[redis]")
    end
  end

  context 'when emptyDir is customized' do
    let(:deployments_values) do
      YAML.safe_load(%(
        gitlab:
          webservice:
            sharedTmpDir:
              sizeLimit: 1G
            sharedUploadDir:
              sizeLimit: 2G
              medium: Memory
      )).deep_merge(default_values)
    end

    it 'properly sets values' do
      t = HelmTemplate.new(deployments_values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

      volumes = t.dig('Deployment/test-webservice-default', 'spec', 'template', 'spec', 'volumes')

      expect(volumes).to include({ "name" => "shared-tmp", "emptyDir" => { "sizeLimit" => "1G" } })
      expect(volumes).to include({ "name" => "shared-upload-directory", "emptyDir" => { "sizeLimit" => "2G", "medium" => "Memory" } })
    end
  end
end
