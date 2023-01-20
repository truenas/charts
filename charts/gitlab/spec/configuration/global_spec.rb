require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'global configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
      global: {}
    ))
  end

  context 'required settings' do
    it 'successfully creates a helm release' do
      t = HelmTemplate.new(default_values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
    end
  end

  context 'default settings' do
    it 'fails to create a helm release' do
      t = HelmTemplate.new({})
      expect(t.exit_code).to eq(256), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
    end
  end

  describe 'registry and geo sync enabled' do
    let(:registry_notifications) do
      YAML.safe_load(%(
        global:
          geo:
            enabled: true
            role: primary
            registry:
              replication:
                enabled: true
                primaryApiUrl: 'http://registry.foobar.com'
          postgresql:
            install: false
          psql:
            host: geo-1.db.example.com
            port: 5432
            password:
              secret: geo
              key: postgresql-password
      )).deep_merge(default_values)
    end

    it 'configures the notification endpoint' do
      t = HelmTemplate.new(registry_notifications)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(t.find_projected_secret('Deployment/test-sidekiq-all-in-1-v2', 'init-sidekiq-secrets', 'test-registry-notification')).to be true
      expect(t.find_projected_secret('Deployment/test-webservice-default', 'init-webservice-secrets', 'test-registry-notification')).to be true
      expect(t.find_projected_secret('Deployment/test-toolbox', 'init-toolbox-secrets', 'test-registry-notification')).to be true
      gitlab_config = t.dig('ConfigMap/test-sidekiq', 'data', 'gitlab.yml.erb')
      expect(gitlab_config).to include('notification_secret')

      config = t.dig('ConfigMap/test-registry', 'data', 'config.yml')
      config_yaml = YAML.safe_load(config, permitted_classes: [Symbol])

      # With geo enabled && syncing of the registry enabled, we insert this notifier
      expect(config_yaml['notifications']['endpoints'].count { |item| item['name'] == 'geo_event' }).to eq(1)
    end
  end

  describe 'registry and geo sync enabled with other notifiers' do
    let(:registry_notifications) do
      YAML.safe_load(%(
        global:
          geo:
            enabled: true
            role: primary
            registry:
              replication:
                enabled: true
                primaryApiUrl: 'http://registry.foobar.com'
          postgresql:
            install: false
          psql:
            host: geo-1.db.example.com
            port: 5432
            password:
              secret: geo
              key: postgresql-password
          registry:
            notifications:
              endpoints:
                - name: FooListener
                  url: https://foolistener.com/event
                  timeout: 500ms
                  threshold: 10
                  ackoff: 1s
                  headers:
                    FooBar: ['1', '2']
                    Authorization:
                      secret: gitlab-registry-authorization-header
                    SpecificPassword:
                      secret: gitlab-registry-specific-password
                      key: password
      )).deep_merge(default_values)
    end

    it 'all notifications are included' do
      t = HelmTemplate.new(registry_notifications)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

      # The below is ugly, both code wise, as well as informing the user testing WHAT is wrong...
      config = t.dig('ConfigMap/test-registry', 'data', 'config.yml')
      config_yaml = YAML.safe_load(config, permitted_classes: [Symbol])

      # Testing that we don't accidentally blow away a customization
      expect(config_yaml['notifications']['endpoints'].count { |item| item['name'] == 'FooListener' }).to eq(1)

      # With geo enabled && syncing of the registry enabled, we insert this notifier
      expect(config_yaml['notifications']['endpoints'].count { |item| item['name'] == 'geo_event' }).to eq(1)
    end
  end
end
