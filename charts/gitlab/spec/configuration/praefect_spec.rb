require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Praefect configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
    ))
  end

  let(:praefect_resources) do
    [
      'Service/test-praefect',
      'ConfigMap/test-praefect',
      'PodDisruptionBudget/test-praefect',
      'StatefulSet/test-praefect'
    ]
  end

  let(:internal_gitaly_resources) do
    [
      'ConfigMap/test-gitaly',
      'PodDisruptionBudget/test-gitaly',
      'Service/test-gitaly',
      'StatefulSet/test-gitaly'
    ]
  end

  let(:gitaly_resources_with_praefect) do
    [
      'ConfigMap/test-gitaly-praefect',
      'PodDisruptionBudget/test-gitaly-default',
      'Service/test-gitaly-default',
      'StatefulSet/test-gitaly-default'
    ]
  end

  context 'with Praefect disabled' do
    let(:values_praefect_disabled) do
      YAML.safe_load(%(
        global:
          praefect:
            enabled: false
      )).deep_merge(default_values)
    end

    let(:template) { HelmTemplate.new(values_praefect_disabled) }

    it 'templates successfully' do
      expect(template.exit_code).to eq(0)
    end

    it 'does not render Praefect resources' do
      praefect_resources.each do |r|
        expect(template.dig(r)).to be_falsey
      end
    end
  end

  context 'with Praefect enabled' do
    let(:values_praefect_enabled) do
      YAML.safe_load(%(
        global:
          praefect:
            enabled: true
      )).deep_merge(default_values)
    end

    let(:template) { HelmTemplate.new(values_praefect_enabled) }

    it 'templates successfully' do
      expect(template.exit_code).to eq(0)
    end

    it 'renders Praefect resources' do
      praefect_resources.each do |r|
        expect(template.dig(r)).to be_truthy
      end
    end

    it 'renders Gitaly resources' do
      gitaly_resources_with_praefect.each do |r|
        expect(template.dig(r)).to be_truthy
      end
    end

    it 'does not render internal Gitaly resources' do
      internal_gitaly_resources.each do |r|
        expect(template.dig(r)).to be_falsey
      end
    end

    context 'without replacing Gitaly' do
      let(:values_with_internal_gitaly) do
        YAML.safe_load(%(
          global:
            praefect:
              replaceInternalGitaly: false
              virtualStorages:
              - name: default-praefect
        )).deep_merge(values_praefect_enabled)
      end

      let(:template) { HelmTemplate.new(values_with_internal_gitaly) }

      it 'renders internal Gitaly resources' do
        internal_gitaly_resources.each do |r|
          expect(template.dig(r)).to be_truthy
        end
      end
    end

    context 'with multiple virtual storages' do
      let(:values_multiple_virtual_storages) do
        YAML.safe_load(%(
          global:
            praefect:
              virtualStorages:
              - name: default
                gitalyReplicas: 3
              - name: vs2
                gitalyReplicas: 3
        )).deep_merge(values_praefect_enabled)
      end

      let(:gitaly_resources_with_multiple_storages) do
        [
          'PodDisruptionBudget/test-gitaly-vs2',
          'Service/test-gitaly-vs2',
          'StatefulSet/test-gitaly-vs2'
        ].concat(gitaly_resources_with_praefect)
      end

      let(:template) { HelmTemplate.new(values_multiple_virtual_storages) }

      it 'templates successfully' do
        expect(template.exit_code).to eq(0)
      end

      it 'generates Gitaly resources per virtual storage' do
        gitaly_resources_with_multiple_storages.each do |r|
          expect(template.dig(r)).to be_truthy
        end
      end
    end

    context 'When customer provides additional labels' do
      let(:values) do
        YAML.safe_load(%(
          global:
            common:
              labels:
                global: global
                foo: global
            pod:
              labels:
                global_pod: true
            service:
              labels:
                global_service: true
          gitlab:
            praefect:
              common:
                labels:
                  global: praefect
                  praefect: praefect
              podLabels:
                pod: true
                global: pod
              serviceLabels:
                service: true
                global: service
        )).deep_merge(values_praefect_enabled)
      end

      it 'Populates the additional labels in the expected manner' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        expect(t.dig('ConfigMap/test-praefect', 'metadata', 'labels')).to include('global' => 'praefect')
        expect(t.dig('PodDisruptionBudget/test-praefect', 'metadata', 'labels')).to include('global' => 'praefect')
        expect(t.dig('Service/test-praefect', 'metadata', 'labels')).to include('global' => 'service')
        expect(t.dig('Service/test-praefect', 'metadata', 'labels')).to include('foo' => 'global')
        expect(t.dig('Service/test-praefect', 'metadata', 'labels')).to include('global_service' => 'true')
        expect(t.dig('Service/test-praefect', 'metadata', 'labels')).to include('service' => 'true')
        expect(t.dig('Service/test-praefect', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(t.dig('StatefulSet/test-praefect', 'metadata', 'labels')).to include('foo' => 'global')
        expect(t.dig('StatefulSet/test-praefect', 'metadata', 'labels')).to include('global' => 'praefect')
        expect(t.dig('StatefulSet/test-praefect', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(t.dig('StatefulSet/test-praefect', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
        expect(t.dig('StatefulSet/test-praefect', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
        expect(t.dig('StatefulSet/test-praefect', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
      end
    end
  end
end
