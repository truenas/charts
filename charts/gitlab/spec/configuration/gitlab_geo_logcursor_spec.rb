require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'geo-logcursor configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
      global:
        geo:
          enabled: true
          role: secondary
          psql:
            host: localhost
            password:
              secret: foobar
        hosts:
          domain: example.com
        psql:
          host: localhost
          password:
            secret: foobar
        serviceAccount:
          create: true
          enabled: true
      postgres:
        install: false
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
          geo-logcursor:
            common:
              labels:
                global: geo-logcursor
                geo-logcursor: geo-logcursor
            podLabels:
              pod: true
              global: pod
      )).deep_merge(default_values)
    end
    it 'Populates the additional labels in the expected manner' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(t.dig('ConfigMap/test-geo-logcursor', 'metadata', 'labels')).to include('global' => 'geo-logcursor')
      expect(t.dig('Deployment/test-geo-logcursor', 'metadata', 'labels')).to include('foo' => 'global')
      expect(t.dig('Deployment/test-geo-logcursor', 'metadata', 'labels')).to include('global' => 'geo-logcursor')
      expect(t.dig('Deployment/test-geo-logcursor', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('Deployment/test-geo-logcursor', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
      expect(t.dig('Deployment/test-geo-logcursor', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
      expect(t.dig('Deployment/test-geo-logcursor', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
      expect(t.dig('ServiceAccount/test-geo-logcursor', 'metadata', 'labels')).to include('global' => 'geo-logcursor')
    end
  end
end
