require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'registry configuration' do
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
        registry:
          common:
            labels:
              global: registry
              registry: registry
          networkpolicy:
            enabled: true
          podLabels:
            pod: true
            global: pod
          serviceAccount:
            create: true
            enabled: true
          serviceLabels:
            service: true
            global: service
      )).deep_merge(default_values)
    end

    it 'Populates the additional labels in the expected manner' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(t.dig('ConfigMap/test-registry', 'metadata', 'labels')).to include('global' => 'registry')
      expect(t.dig('Deployment/test-registry', 'metadata', 'labels')).to include('foo' => 'global')
      expect(t.dig('Deployment/test-registry', 'metadata', 'labels')).to include('global' => 'registry')
      expect(t.dig('Deployment/test-registry', 'metadata', 'labels')).not_to include('global' => 'pod')
      expect(t.dig('Deployment/test-registry', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('Deployment/test-registry', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
      expect(t.dig('Deployment/test-registry', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
      expect(t.dig('Deployment/test-registry', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
      expect(t.dig('HorizontalPodAutoscaler/test-registry', 'metadata', 'labels')).to include('global' => 'registry')
      expect(t.dig('Ingress/test-registry', 'metadata', 'labels')).to include('global' => 'registry')
      expect(t.dig('NetworkPolicy/test-registry-v1', 'metadata', 'labels')).to include('global' => 'registry')
      expect(t.dig('PodDisruptionBudget/test-registry-v1', 'metadata', 'labels')).to include('global' => 'registry')
      expect(t.dig('Service/test-registry', 'metadata', 'labels')).to include('global' => 'service')
      expect(t.dig('Service/test-registry', 'metadata', 'labels')).to include('global_service' => 'true')
      expect(t.dig('Service/test-registry', 'metadata', 'labels')).to include('service' => 'true')
      expect(t.dig('Service/test-registry', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('ServiceAccount/test-registry', 'metadata', 'labels')).to include('global' => 'registry')
    end
  end
end
