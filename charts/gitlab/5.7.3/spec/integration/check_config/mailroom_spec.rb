require 'spec_helper'
require 'check_config_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'checkConfig mailroom' do
  describe 'incomingEmail.microsoftGraph' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            incomingEmail:
              enabled: true
              inboxMethod: microsoft_graph
              tenantId: MY-TENANT-ID
              clientId: MY-CLIENT-ID
              clientSecret:
                secret: secret
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            incomingEmail:
              enabled: true
              inboxMethod: microsoft_graph
              clientSecret:
                secret: secret
      )).merge(default_required_values)
    end

    let(:error_output) { 'be sure to specify the tenant ID' }

    include_examples 'config validation',
                     success_description: 'when incomingEmail is configured with Microsoft Graph',
                     error_description: 'when incomingEmail is missing required Microsoft Graph settings'
  end

  describe 'serviceDesk.microsoftGraph' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            incomingEmail:
              enabled: true
              inboxMethod: microsoft_graph
              tenantId: MY-TENANT-ID
              clientId: MY-CLIENT-ID
              clientSecret:
                secret: secret
            serviceDesk:
              enabled: true
              inboxMethod: microsoft_graph
              tenantId: MY-TENANT-ID
              clientId: MY-CLIENT-ID
              clientSecret:
                secret: secret
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            incomingEmail:
              enabled: true
              inboxMethod: microsoft_graph
              tenantId: MY-TENANT-ID
              clientId: MY-CLIENT-ID
              clientSecret:
                secret: secret
            serviceDesk:
              enabled: true
              inboxMethod: microsoft_graph
              clientSecret:
                secret: secret
      )).merge(default_required_values)
    end

    let(:error_output) { 'be sure to specify the tenant ID' }

    include_examples 'config validation',
                     success_description: 'when serviceDesk is configured with Microsoft Graph',
                     error_description: 'when serviceDesk is missing required Microsoft Graph settings'
  end

  describe 'incomingEmail.deliveryMethod' do
    include_context 'check config setup'

    context 'with valid incoming mail sidekiq config' do
      let(:values) do
        YAML.safe_load(%(
        global:
          appConfig:
            incomingEmail:
              enabled: true
              password:
                secret: "password"
              deliveryMethod: sidekiq
            serviceDeskEmail:
              enabled: false
        )).deep_merge(default_required_values)
      end

      it 'succeeds' do
        expect(stderr).to be_empty
        expect(exit_code).to eq(0)
        expect(stdout).to include('name: gitlab-checkconfig-test')
      end
    end

    context 'with valid incoming mail webhook config' do
      let(:values) do
        YAML.safe_load(%(
        global:
          appConfig:
            incomingEmail:
              enabled: true
              password:
                secret: "password"
              deliveryMethod: webhook
            serviceDeskEmail:
              enabled: false
        )).deep_merge(default_required_values)
      end

      it 'succeeds' do
        expect(stderr).to be_empty
        expect(exit_code).to eq(0)
        expect(stdout).to include('name: gitlab-checkconfig-test')
      end
    end

    context 'delivery method is unknown' do
      let(:values) do
        YAML.safe_load(%(
        global:
          appConfig:
            incomingEmail:
              enabled: true
              password:
                secret: "password"
              deliveryMethod: somethingElse
            serviceDeskEmail:
              enabled: false
        )).deep_merge(default_required_values)
      end

      it 'returns an error' do
        expect(exit_code).to be > 0
        expect(stdout).to be_empty
        expect(stderr).to include('Delivery method should be either "sidekiq" or "webhook"')
      end
    end
  end

  describe 'serviceDeskEmail.deliveryMethod' do
    include_context 'check config setup'

    context 'with valid service desk mail sidekiq config' do
      let(:values) do
        YAML.safe_load(%(
        global:
          appConfig:
            incomingEmail:
              enabled: true
              address: "something+%{key}@gmail.com"
              password:
                secret: "password"
              deliveryMethod: sidekiq
            serviceDeskEmail:
              enabled: true
              address: "something+%{key}@gmail.com"
              password:
                secret: "password"
              deliveryMethod: sidekiq
        )).deep_merge(default_required_values)
      end

      it 'succeeds' do
        puts stderr
        expect(stderr).to be_empty
        expect(exit_code).to eq(0)
        expect(stdout).to include('name: gitlab-checkconfig-test')
      end
    end

    context 'with valid service desk mail sidekiq config' do
      let(:values) do
        YAML.safe_load(%(
        global:
          appConfig:
            incomingEmail:
              enabled: true
              address: "something+%{key}@gmail.com"
              password:
                secret: "password"
              deliveryMethod: sidekiq
            serviceDeskEmail:
              enabled: true
              address: "something+%{key}@gmail.com"
              password:
                secret: "password"
              deliveryMethod: webhook
        )).deep_merge(default_required_values)
      end

      it 'succeeds' do
        expect(stderr).to be_empty
        expect(exit_code).to eq(0)
        expect(stdout).to include('name: gitlab-checkconfig-test')
      end
    end

    context 'delivery method is unknown' do
      let(:values) do
        YAML.safe_load(%(
        global:
          appConfig:
            incomingEmail:
              enabled: true
              address: "something+%{key}@gmail.com"
              password:
                secret: "password"
              deliveryMethod: sidekiq
            serviceDeskEmail:
              enabled: true
              address: "something+%{key}@gmail.com"
              password:
                secret: "password"
              deliveryMethod: somethingElse
        )).deep_merge(default_required_values)
      end

      it 'returns an error' do
        expect(exit_code).to be > 0
        expect(stdout).to be_empty
        expect(stderr).to include('Delivery method should be either "sidekiq" or "webhook"')
      end
    end
  end
end
