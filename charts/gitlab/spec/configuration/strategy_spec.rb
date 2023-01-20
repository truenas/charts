require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Strategy configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
    ))
  end

  let(:chart_values) do
    YAML.safe_load(%(
      global:
        kas:
          enabled: true
        geo:
          enabled: true
          role: secondary
          psql:
            host: localhost
            password:
              secret: foobar
        psql:
          host: localhost
          password:
            secret: foobar
        pages:
          enabled: true
        praefect:
          enabled: true
        appConfig:
          incomingEmail:
            enabled: true
            password:
              secret: foo
          gitlab_kas:
            key: secret_key
            secret: secret_name
            internalUrl: grpc://custom-internal-url.example.com
      gitlab:
        kas:
          deployment:
            strategy:
              type: Recreate
        geo-logcursor:
          deployment:
            strategy:
              type: Recreate
        mailroom:
          deployment:
            strategy:
              type: Recreate
        gitaly:
          statefulset:
            strategy:
              type: Recreate
        sidekiq:
          pods:
          - name: test
            strategy:
              type: Recreate
          - name: test2
            strategy:
              type: Recreate
        gitlab-pages:
          deployment:
            strategy:
              type: Recreate
        gitlab-shell:
          deployment:
            strategy:
              type: Recreate
        gitlab-exporter:
          deployment:
            strategy:
              type: Recreate
        webservice:
          deployment:
            strategy:
              type: Recreate
        praefect:
          statefulset:
            strategy:
              type: Recreate
      registry:
        deployment:
          strategy:
            type: Recreate
    )).deep_merge(default_values)
  end

  let(:ignored_charts) do
    [
      'Deployment/test-certmanager-cainjector',
      'Deployment/test-certmanager-webhook',
      'Deployment/test-certmanager',
      'Deployment/test-prometheus-server',
      'Deployment/test-nginx-ingress-controller',
      'Deployment/test-nginx-ingress-defaultbackend',
      'Deployment/test-toolbox',
      'Deployment/test-minio',
      'Deployment/test-gitlab-runner',
      'StatefulSet/test-redis-master',
      'StatefulSet/test-postgresql'
    ]
  end

  context 'When using default settings' do
    let(:template) { HelmTemplate.new(default_values) }

    it 'Templates successfully' do
      expect(template.exit_code).to eq(0), "Unexpected error code #{template.exit_code} -- #{template.stderr}"
    end

    it 'Check undefined strategy for Deployment templates' do
      resources_by_kind = template.resources_by_kind('Deployment').reject { |key, _| ignored_charts.include? key }

      resources_by_kind.each do |key, _|
        expect(template.dig(key, 'spec', 'strategy')).to be_falsey
      end
    end

    it 'Check undefined strategy for StatefulSet templates' do
      resources_by_kind = template.resources_by_kind('StatefulSet').reject { |key, _| ignored_charts.include? key }

      resources_by_kind.each do |key, _|
        expect(template.dig(key, 'spec', 'updateStrategy')).to be_falsey
      end
    end
  end

  context 'When populating a chart strategy property' do
    let(:local_template) { HelmTemplate.new(chart_values) }

    it 'Templates successfully' do
      expect(local_template.exit_code).to eq(0), "Unexpected error code #{local_template.exit_code} -- #{local_template.stderr}"
    end

    it 'Check strategy type for Deployment templates' do
      resources_by_kind = local_template.resources_by_kind('Deployment').reject { |key, _| ignored_charts.include? key }

      resources_by_kind.each do |key, _|
        resource = local_template.dig(key, 'spec', 'strategy')
        expect(resource).not_to be_nil, "Unable to find strategy for #{key}"
        expect(resource['type']).to eq('Recreate'), "#{key} Deployment strategy: #{resource['type']}"
      end
    end

    it 'Check strategy type for StatefulSet templates' do
      resources_by_kind = local_template.resources_by_kind('StatefulSet').reject { |key, _| ignored_charts.include? key }

      resources_by_kind.each do |key, _|
        expect(local_template.dig(key, 'spec', 'updateStrategy')['type']).to eq('Recreate')
      end
    end
  end
end
