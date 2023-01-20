require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Sidekiq configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com

      # required to activate mailroom
      gitlab:
        sidekiq:
          pods:
          - name: pod-1
            queues: merge
          - name: pod-2
            negateQueues: merge
    ))
  end

  context 'when setting extraEnv' do
    def container_name(pod)
      "Deployment/test-sidekiq-#{pod}-v2"
    end

    context 'when the global value is set' do
      let(:global_values) do
        YAML.safe_load(%(
          global:
            extraEnv:
              EXTRA_ENV_VAR_A: global-a
              EXTRA_ENV_VAR_B: global-b
        )).deep_merge(default_values)
      end

      it 'sets those environment variables on each pod' do
        global_template = HelmTemplate.new(global_values)

        expect(global_template.exit_code).to eq(0)

        expect(global_template.env(container_name('pod-1'), 'sidekiq'))
          .to include(
                { 'name' => 'EXTRA_ENV_VAR_A', 'value' => 'global-a' },
                { 'name' => 'EXTRA_ENV_VAR_B', 'value' => 'global-b' }
              )

        expect(global_template.env(container_name('pod-2'), 'sidekiq'))
          .to include(
                { 'name' => 'EXTRA_ENV_VAR_A', 'value' => 'global-a' },
                { 'name' => 'EXTRA_ENV_VAR_B', 'value' => 'global-b' }
              )
      end

      context 'when the chart-level value is set' do
        let(:chart_values) do
          YAML.safe_load(%(
            gitlab:
              sidekiq:
                extraEnv:
                  EXTRA_ENV_VAR_A: chart-a
                  EXTRA_ENV_VAR_C: chart-c
                  EXTRA_ENV_VAR_D: chart-d
          ))
        end

        let(:chart_template) { HelmTemplate.new(global_values.deep_merge(chart_values)) }

        it 'sets those environment variables on each pod' do
          expect(chart_template.exit_code).to eq(0)

          expect(chart_template.env(container_name('pod-1'), 'sidekiq'))
            .to include(
                  { 'name' => 'EXTRA_ENV_VAR_C', 'value' => 'chart-c' },
                  { 'name' => 'EXTRA_ENV_VAR_D', 'value' => 'chart-d' }
                )

          expect(chart_template.env(container_name('pod-2'), 'sidekiq'))
            .to include(
                  { 'name' => 'EXTRA_ENV_VAR_C', 'value' => 'chart-c' },
                  { 'name' => 'EXTRA_ENV_VAR_D', 'value' => 'chart-d' }
                )
        end

        it 'overrides global values' do
          expect(chart_template.env(container_name('pod-1'), 'sidekiq'))
            .to include('name' => 'EXTRA_ENV_VAR_A', 'value' => 'chart-a')

          expect(chart_template.env(container_name('pod-2'), 'sidekiq'))
            .to include('name' => 'EXTRA_ENV_VAR_A', 'value' => 'chart-a')
        end

        context 'when the pod-level value is set' do
          let(:pod_values) do
            YAML.safe_load(%(
              gitlab:
                sidekiq:
                  pods:
                  - name: pod-1
                    queues: merge
                    extraEnv:
                      EXTRA_ENV_VAR_B: pod-b
                      EXTRA_ENV_VAR_C: pod-c
                      EXTRA_ENV_VAR_E: pod-e
                  - name: pod-2
                    negateQueues: merge
                    extraEnv:
                      EXTRA_ENV_VAR_B: pod-b
                      EXTRA_ENV_VAR_C: pod-c
                      EXTRA_ENV_VAR_F: pod-f
            ))
          end

          let(:pod_template) do
            HelmTemplate.new(global_values.deep_merge(chart_values).deep_merge(pod_values))
          end

          it 'sets those environment variables on the relevant pods' do
            expect(pod_template.exit_code).to eq(0)

            expect(pod_template.env(container_name('pod-1'), 'sidekiq'))
              .to include('name' => 'EXTRA_ENV_VAR_E', 'value' => 'pod-e')
            expect(pod_template.env(container_name('pod-1'), 'sidekiq'))
              .not_to include('name' => 'EXTRA_ENV_VAR_F', 'value' => 'pod-f')

            expect(pod_template.env(container_name('pod-2'), 'sidekiq'))
              .not_to include('name' => 'EXTRA_ENV_VAR_E', 'value' => 'pod-e')
            expect(pod_template.env(container_name('pod-2'), 'sidekiq'))
              .to include('name' => 'EXTRA_ENV_VAR_F', 'value' => 'pod-f')
          end

          it 'overrides global values' do
            expect(pod_template.env(container_name('pod-1'), 'sidekiq'))
              .to include('name' => 'EXTRA_ENV_VAR_B', 'value' => 'pod-b')

            expect(pod_template.env(container_name('pod-2'), 'sidekiq'))
              .to include('name' => 'EXTRA_ENV_VAR_B', 'value' => 'pod-b')
          end

          it 'overrides chart-level values' do
            expect(pod_template.env(container_name('pod-1'), 'sidekiq'))
              .to include('name' => 'EXTRA_ENV_VAR_C', 'value' => 'pod-c')

            expect(pod_template.env(container_name('pod-2'), 'sidekiq'))
              .to include('name' => 'EXTRA_ENV_VAR_C', 'value' => 'pod-c')
          end
        end
      end
    end
  end

  context 'when configuring monitoring' do
    let(:values) { default_values }
    let(:template) { HelmTemplate.new(values) }
    let(:gitlab_yml) { YAML.safe_load(template.dig('ConfigMap/test-sidekiq', 'data', 'gitlab.yml.erb')) }
    let(:monitoring) { gitlab_yml.dig('production', 'monitoring') }

    context 'sidekiq_exporter' do
      context 'when not configured' do
        it 'uses default settings' do
          expect(monitoring).to include(
            'sidekiq_exporter' => {
              'enabled' => true,
              'address' => '0.0.0.0',
              'port' => 3807
            }
          )
        end
      end

      context 'when disabled' do
        let(:values) do
          YAML.safe_load(%(
            gitlab:
              sidekiq:
                metrics:
                  enabled: false
          )).deep_merge(default_values)
        end

        it 'emits empty hash' do
          expect(monitoring['sidekiq_exporter']).to be(nil)
        end
      end

      context 'when custom values are set' do
        let(:values) do
          YAML.safe_load(%(
            gitlab:
              sidekiq:
                metrics:
                  enabled: true
                  port: 2222
          )).deep_merge(default_values)
        end

        it 'uses these settings' do
          expect(monitoring).to include(
            'sidekiq_exporter' => {
              'enabled' => true,
              'address' => '0.0.0.0',
              'port' => 2222
            }
          )
        end
      end
    end

    context 'sidekiq_health_checks' do
      context 'when not configured' do
        it 'uses default settings' do
          expect(monitoring).to include(
            'sidekiq_health_checks' => {
              'enabled' => true,
              'address' => '0.0.0.0',
              'port' => 3807
            }
          )
        end

        context 'when sidekiq_exporter is configured' do
          let(:values) do
            YAML.safe_load(%(
              gitlab:
                sidekiq:
                  metrics:
                    enabled: true
                    port: 2222
                  health_checks:
                    enabled: true
            )).deep_merge(default_values)
          end

          it 'inherits its settings' do
            expect(monitoring).to include(
              'sidekiq_health_checks' => {
                'enabled' => true,
                'address' => '0.0.0.0',
                'port' => 2222
              }
            )
          end
        end
      end

      context 'when disabled' do
        let(:values) do
          YAML.safe_load(%(
            gitlab:
              sidekiq:
                health_checks:
                  enabled: false
          )).deep_merge(default_values)
        end

        it 'emits empty hash' do
          expect(monitoring['sidekiq_health_checks']).to be(nil)
        end
      end

      context 'when custom values are set' do
        let(:values) do
          YAML.safe_load(%(
            gitlab:
              sidekiq:
                health_checks:
                  enabled: true
                  port: 2222
          )).deep_merge(default_values)
        end

        it 'uses these settings' do
          expect(monitoring).to include(
            'sidekiq_health_checks' => {
              'enabled' => true,
              'address' => '0.0.0.0',
              'port' => 2222
            }
          )
        end
      end
    end
  end

  context 'when configuring memoryKiller' do
    let(:default_values) do
      YAML.safe_load(%(
        certmanager-issuer:
          email: test@example.com
      ))
    end

    let(:hard_limit) do
      YAML.safe_load(%(
        gitlab:
          sidekiq:
            memoryKiller:
              hardLimitRss: 9000000
      )).deep_merge(default_values)
    end

    it 'uses defaults or uses chart global values' do
      t = HelmTemplate.new(default_values)

      expect(t.exit_code).to eq(0)
      expect(t.env(
        'Deployment/test-sidekiq-all-in-1-v2',
        'sidekiq')).to include(
          { 'name' => 'SIDEKIQ_DAEMON_MEMORY_KILLER', 'value' => '1' },
          { 'name' => 'SIDEKIQ_MEMORY_KILLER_CHECK_INTERVAL', 'value' => '3' },
          { 'name' => 'SIDEKIQ_MEMORY_KILLER_MAX_RSS', 'value' => '2000000' },
          { 'name' => 'SIDEKIQ_MEMORY_KILLER_GRACE_TIME', 'value' => '900' },
          { 'name' => 'SIDEKIQ_MEMORY_KILLER_SHUTDOWN_WAIT', 'value' => '30' }
        )

      expect(t.env(
        'Deployment/test-sidekiq-all-in-1-v2',
        'sidekiq')).not_to include(
          { 'name' => 'SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS' }
        )
    end

    it 'configures the hard limit' do
      t = HelmTemplate.new(hard_limit)

      expect(t.exit_code).to eq(0)
      expect(t.env(
        'Deployment/test-sidekiq-all-in-1-v2',
        'sidekiq')).to include(
          { 'name' => 'SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS', 'value' => '9000000' }
        )
    end

    context 'uses pod level configurations' do
      let(:pod_zero) do
        YAML.safe_load(%(
          name: s0
          queues: zero
        ))
      end

      let(:pod_one) do
        YAML.safe_load(%(
          name: s1
          queues: one
          memoryKiller:
            maxRss: 9
        ))
      end

      let(:minimum_multi_pod_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              pods: [#{pod_zero.to_json}]
        )).deep_merge!(default_values)
      end

      let(:override_multi_pod_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              pods: [#{pod_zero.to_json}, #{pod_one.to_json}]
        )).deep_merge!(default_values)
      end

      it 'with the chart defaults' do
        t = HelmTemplate.new(minimum_multi_pod_values)

        expect(t.exit_code).to eq(0)
        expect(t.env(
          'Deployment/test-sidekiq-s0-v2',
          'sidekiq')).to include(
            { 'name' => 'SIDEKIQ_DAEMON_MEMORY_KILLER', 'value' => '1' },
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_CHECK_INTERVAL', 'value' => '3' },
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_MAX_RSS', 'value' => '2000000' },
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_GRACE_TIME', 'value' => '900' },
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_SHUTDOWN_WAIT', 'value' => '30' }
          )

        expect(t.env(
          'Deployment/test-sidekiq-s0-v2',
          'sidekiq')).not_to include(
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS' }
          )
      end

      it 'with pod overrides' do
        t = HelmTemplate.new(override_multi_pod_values)

        expect(t.exit_code).to eq(0)
        expect(t.env(
          'Deployment/test-sidekiq-s0-v2',
          'sidekiq')).not_to include(
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_HARD_LIMIT_RSS' }
          )

        expect(t.env(
          'Deployment/test-sidekiq-s1-v2',
          'sidekiq')).to include(
            { 'name' => 'SIDEKIQ_MEMORY_KILLER_MAX_RSS', 'value' => '9' },
          )
      end
    end
  end

  context 'When customer provides additional labels' do
    let(:labels) do
      YAML.safe_load(%(
        global:
          common:
            labels:
              global: global
              foo: global
          pod:
            labels:
              global_pod: true
        gitlab:
          sidekiq:
            common:
              labels:
                global: sidekiq
                sidekiq: sidekiq
            networkpolicy:
              enabled: true
            podLabels:
              pod: true
              global: pod
            serviceAccount:
              create: true
              enabled: true
      ))
    end

    context 'using the all-in-one' do
      let(:default_values) do
        YAML.safe_load(%(
          certmanager-issuer:
            email: test@example.com
        )).deep_merge(labels)
      end

      it 'Populates the additional labels in the expected manner' do
        t = HelmTemplate.new(default_values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        expect(t.dig('ConfigMap/test-sidekiq', 'metadata', 'labels')).to include('global' => 'sidekiq')
        expect(t.dig('Deployment/test-sidekiq-all-in-1-v2', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(t.dig('Deployment/test-sidekiq-all-in-1-v2', 'metadata', 'labels')).to include('global' => 'sidekiq')
        expect(t.dig('Deployment/test-sidekiq-all-in-1-v2', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
        expect(t.dig('Deployment/test-sidekiq-all-in-1-v2', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
        expect(t.dig('Deployment/test-sidekiq-all-in-1-v2', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
        expect(t.dig('HorizontalPodAutoscaler/test-sidekiq-all-in-1-v2', 'metadata', 'labels')).to include('global' => 'sidekiq')
        expect(t.dig('NetworkPolicy/test-sidekiq-v1', 'metadata', 'labels')).to include('global' => 'sidekiq')
        expect(t.dig('PodDisruptionBudget/test-sidekiq-all-in-1-v1', 'metadata', 'labels')).to include('global' => 'sidekiq')
        expect(t.dig('ServiceAccount/test-sidekiq', 'metadata', 'labels')).to include('global' => 'sidekiq')
      end
    end

    context 'using the multiple deployments' do
      let(:default_values) do
        YAML.safe_load(%(
          certmanager-issuer:
            email: test@example.com
          gitlab:
            sidekiq:
              pods:
              - name: pod-1
                queues: merge
              - name: pod-2
                negateQueues: merge
                podLabels:
                  deployment: negateQueues
                  sidekiq: pod-2
              - name: pod-3
                fooQueue: merge
                podLabels:
                  sidekiq: pod-label-3
                common:
                  labels:
                    deployment: fooQueue
                    sidekiq: pod-common-3
        )).deep_merge(labels)
      end

      it 'Populates the additional labels in the expected manner' do
        t = HelmTemplate.new(default_values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        expect(t.dig('ConfigMap/test-sidekiq', 'metadata', 'labels')).to include('global' => 'sidekiq')
        expect(t.dig('Deployment/test-sidekiq-pod-1-v2', 'metadata', 'labels')).to include('foo' => 'global')
        expect(t.dig('Deployment/test-sidekiq-pod-1-v2', 'metadata', 'labels')).to include('sidekiq' => 'sidekiq')
        expect(t.dig('Deployment/test-sidekiq-pod-1-v2', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(t.dig('Deployment/test-sidekiq-pod-1-v2', 'metadata', 'labels')).to include('global' => 'sidekiq')
        expect(t.dig('Deployment/test-sidekiq-pod-1-v2', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
        expect(t.dig('Deployment/test-sidekiq-pod-1-v2', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
        expect(t.dig('Deployment/test-sidekiq-pod-1-v2', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
        expect(t.dig('Deployment/test-sidekiq-pod-2-v2', 'spec', 'template', 'metadata', 'labels')).to include('deployment' => 'negateQueues')
        expect(t.dig('Deployment/test-sidekiq-pod-2-v2', 'spec', 'template', 'metadata', 'labels')).to include('sidekiq' => 'pod-2')
        expect(t.dig('Deployment/test-sidekiq-pod-3-v2', 'spec', 'template', 'metadata', 'labels')).to include('deployment' => 'fooQueue')
        expect(t.dig('Deployment/test-sidekiq-pod-3-v2', 'metadata', 'labels')).to include('sidekiq' => 'pod-common-3')
        expect(t.dig('Deployment/test-sidekiq-pod-3-v2', 'metadata', 'labels')).not_to include('sidekiq' => 'pod-label-3')
        expect(t.dig('Deployment/test-sidekiq-pod-3-v2', 'metadata', 'labels')).not_to include('sidekiq' => 'sidekiq')
        expect(t.dig('Deployment/test-sidekiq-pod-3-v2', 'spec', 'template', 'metadata', 'labels')).to include('sidekiq' => 'pod-label-3')
        expect(t.dig('Deployment/test-sidekiq-pod-3-v2', 'spec', 'template', 'metadata', 'labels')).not_to include('sidekiq' => 'pod-common-3')
        expect(t.dig('Deployment/test-sidekiq-pod-3-v2', 'spec', 'template', 'metadata', 'labels')).not_to include('sidekiq' => 'sidekiq')
        expect(t.dig('HorizontalPodAutoscaler/test-sidekiq-pod-1-v2', 'metadata', 'labels')).to include('global' => 'sidekiq')
        expect(t.dig('HorizontalPodAutoscaler/test-sidekiq-pod-3-v2', 'metadata', 'labels')).to include('sidekiq' => 'pod-common-3')
        expect(t.dig('HorizontalPodAutoscaler/test-sidekiq-pod-3-v2', 'metadata', 'labels')).not_to include('sidekiq' => 'pod-label-3')
        expect(t.dig('HorizontalPodAutoscaler/test-sidekiq-pod-3-v2', 'metadata', 'labels')).not_to include('sidekiq' => 'sidekiq')
        expect(t.dig('PodDisruptionBudget/test-sidekiq-pod-3-v1', 'metadata', 'labels')).to include('sidekiq' => 'pod-common-3')
        expect(t.dig('PodDisruptionBudget/test-sidekiq-pod-3-v1', 'metadata', 'labels')).not_to include('sidekiq' => 'pod-label-3')
        expect(t.dig('PodDisruptionBudget/test-sidekiq-pod-3-v1', 'metadata', 'labels')).not_to include('sidekiq' => 'sidekiq')
        expect(t.dig('NetworkPolicy/test-sidekiq-v1', 'metadata', 'labels')).to include('global' => 'sidekiq')
        expect(t.dig('PodDisruptionBudget/test-sidekiq-pod-1-v1', 'metadata', 'labels')).to include('global' => 'sidekiq')
        expect(t.dig('ServiceAccount/test-sidekiq', 'metadata', 'labels')).to include('global' => 'sidekiq')
      end
    end
  end

  describe 'terminationGracePeriodSeconds' do
    let(:default_values) do
      YAML.safe_load(%(
        certmanager-issuer:
          email: 'test@example.com'
      ))
    end

    context 'with default deployment-global value and no pod-local value' do
      it 'sets default deployment-global value for terminationGracePeriodSeconds in the Pod spec' do
        t = HelmTemplate.new(default_values)
        expect(t.dig('Deployment/test-sidekiq-all-in-1-v2', 'spec', 'template', 'spec', 'terminationGracePeriodSeconds')).to eq(30)
      end
    end

    context 'with user specified deployment-global value' do
      let(:chart_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              deployment:
                terminationGracePeriodSeconds: 60
        ))
      end

      it 'sets user specified deployment-global value for terminationGracePeriodSeconds in the Pod spec' do
        t = HelmTemplate.new(default_values.deep_merge(chart_values))
        expect(t.dig('Deployment/test-sidekiq-all-in-1-v2', 'spec', 'template', 'spec', 'terminationGracePeriodSeconds')).to eq(60)
      end
    end

    context 'with user specified pod-local value' do
      let(:chart_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              pods:
                - name: 'pod-1'
                  queues: 'merge'
                  terminationGracePeriodSeconds: 55
             ))
      end

      it 'sets user specified pod-local value for terminationGracePeriodSeconds in the Pod spec' do
        t = HelmTemplate.new(default_values.deep_merge(chart_values))
        expect(t.dig('Deployment/test-sidekiq-pod-1-v2', 'spec', 'template', 'spec', 'terminationGracePeriodSeconds')).to eq(55)
      end
    end

    context 'with user specified deployment-global and pod-local values' do
      let(:chart_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              deployment:
                terminationGracePeriodSeconds: 77
              pods:
                - name: 'pod-1'
                  queues: 'merge'
                  terminationGracePeriodSeconds: 66
                - name: 'pod-2'
                  queues: 'zero'
        ))
      end

      it 'sets user specified pod-local value for terminationGracePeriodSeconds in the Pod spec' do
        t = HelmTemplate.new(default_values.deep_merge(chart_values))
        expect(t.dig('Deployment/test-sidekiq-pod-1-v2', 'spec', 'template', 'spec', 'terminationGracePeriodSeconds')).to eq(66)
      end

      it 'sets user specified deployment-global value for terminationGracePeriodSeconds in the Pod spec where pod-local value is not set' do
        t = HelmTemplate.new(default_values.deep_merge(chart_values))
        expect(t.dig('Deployment/test-sidekiq-pod-2-v2', 'spec', 'template', 'spec', 'terminationGracePeriodSeconds')).to eq(77)
      end
    end
  end
end
