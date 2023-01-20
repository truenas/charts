require 'spec_helper'
require 'check_config_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'checkConfig template' do
  # This is not actually in _checkConfig.tpl, but it uses `required`, so
  # acts in a similar way
  describe 'certmanager-issuer.email' do
    let(:success_values) { default_required_values }
    let(:error_values) { {} }
    let(:error_output) { 'Please set certmanager-issuer.email' }

    include_examples 'config validation',
                     success_description: 'when set',
                     error_description: 'when unset'
  end

  describe 'multipleRedis' do
    let(:success_values) do
      YAML.safe_load(%(
        redis:
          install: true
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        redis:
          install: true
        global:
          redis:
            cache:
              host: foo
      )).merge(default_required_values)
    end

    let(:error_output) { 'If configuring multiple Redis servers, you can not use the in-chart Redis server' }

    include_examples 'config validation',
                     success_description: 'when Redis is set to install with a single Redis instance',
                     error_description: 'when Redis is set to install with multiple Redis instances'
  end
end
