require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'migrations configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
      global: {}
      gitlab:
        migrations:
          networkpolicy:
            enabled: true
          serviceAccount:
            enabled: true
            create: true
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
        gitlab:
          migrations:
            common:
              labels:
                global: migrations
                migrations: migrations
            podLabels:
              pod: true
              global: pod
      )).deep_merge(default_values)
    end
    it 'Populates the additional labels in the expected manner' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(t.dig('ConfigMap/test-migrations', 'metadata', 'labels')).to include('global' => 'migrations')
      expect(t.dig('Job/test-migrations-1', 'metadata', 'labels')).to include('foo' => 'global')
      expect(t.dig('Job/test-migrations-1', 'metadata', 'labels')).to include('global' => 'migrations')
      expect(t.dig('Job/test-migrations-1', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('Job/test-migrations-1', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
      expect(t.dig('Job/test-migrations-1', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
      expect(t.dig('Job/test-migrations-1', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
      expect(t.dig('ServiceAccount/test-migrations', 'metadata', 'labels')).to include('global' => 'migrations')
    end
  end
end
