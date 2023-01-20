require 'spec_helper'
require 'check_config_helper'
require 'hash_deep_merge'

describe 'checkConfig webservice' do
  describe 'appConfig.maxRequestDurationSeconds' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            maxRequestDurationSeconds: 50
            webservice:
              workerTimeout: 60
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            maxRequestDurationSeconds: 70
            webservice:
              workerTimeout: 60
      )).merge(default_required_values)
    end

    let(:error_output) { 'global.appConfig.maxRequestDurationSeconds (70) is greater than or equal to global.webservice.workerTimeout (60)' }

    include_examples 'config validation',
                     success_description: 'when maxRequestDurationSeconds is less than workerTimeout',
                     error_description: 'when maxRequestDurationSeconds is greater than or equal to workerTimeout'
  end

  describe 'webserviceTermination' do
    let(:success_values) do
      YAML.safe_load(%(
        gitlab:
          webservice:
            deployment:
              terminationGracePeriodSeconds: 50
            shutdown:
              blackoutSeconds: 10
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        gitlab:
          webservice:
            deployment:
              terminationGracePeriodSeconds: 5
            shutdown:
              blackoutSeconds: 20
      )).merge(default_required_values)
    end

    let(:error_output) { 'fail' }

    include_examples 'config validation',
                     success_description: 'when terminationGracePeriodSeconds is >= blackoutSeconds',
                     error_description: 'when terminationGracePeriodSeconds is < blackoutSeconds'
  end
end
