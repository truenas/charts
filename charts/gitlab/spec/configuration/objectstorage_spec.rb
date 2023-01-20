require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'ObjectStorage configuration' do
  let(:objectstorage_config_file) { '/etc/gitlab/objectstorage/dependency_proxy' }

  let(:services) do
    [
      'sidekiq',
      'webservice',
      'toolbox'
    ]
  end

  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
    ))
  end

  let(:values_dependencyProxy_connection) do
    YAML.safe_load(%(
      global:
        appConfig:
          dependencyProxy:
            connection:
              secret: gitlab-object-storage
              key: connection
    )).deep_merge(default_values)
  end

  let(:values_dependencyProxy_enabled) do
    YAML.safe_load(%(
      global:
        appConfig:
          dependencyProxy:
            enabled: true
    )).deep_merge(default_values)
  end

  describe 'global.appConfig.dependencyProxy.enabled' do
    context 'when true' do
      it 'does not populate connection block' do
        t = HelmTemplate.new(values_dependencyProxy_enabled)
        expect(t.exit_code).to eq(0)
        services.each do |cm|
          expect(t.dig("ConfigMap/test-#{cm}", 'data', 'gitlab.yml.erb')).not_to include(objectstorage_config_file)
        end
      end

      context 'with connection configuration provided' do
        it 'populates connection block' do
          t = HelmTemplate.new(values_dependencyProxy_enabled.deep_merge(values_dependencyProxy_connection))
          expect(t.exit_code).to eq(0)
          services.each do |cm|
            expect(t.dig("ConfigMap/test-#{cm}", 'data', 'gitlab.yml.erb')).to include(objectstorage_config_file)
          end
        end
      end
    end

    context 'when false' do
      it 'does not populate connection block' do
        t = HelmTemplate.new(default_values)
        expect(t.exit_code).to eq(0)
        services.each do |cm|
          expect(t.dig("ConfigMap/test-#{cm}", 'data', 'gitlab.yml.erb')).not_to include(objectstorage_config_file)
        end
      end

      context 'with connection configuration provided' do
        it 'does not populate connection block' do
          t = HelmTemplate.new(values_dependencyProxy_connection)
          expect(t.exit_code).to eq(0)
          services.each do |cm|
            expect(t.dig("ConfigMap/test-#{cm}", 'data', 'gitlab.yml.erb')).not_to include(objectstorage_config_file)
          end
        end
      end
    end
  end
end
