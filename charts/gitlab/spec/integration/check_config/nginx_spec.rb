require 'spec_helper'
require 'check_config_helper'
require 'hash_deep_merge'

describe 'checkConfig nginx' do
  describe 'nginx-ingress.rbac.scope' do
    let(:success_values) do
      YAML.safe_load(%(
        nginx-ingress:
          rbac:
            scope: false
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        nginx-ingress:
          rbac:
            scope: true
      )).merge(default_required_values)
    end

    let(:error_output) { 'Namespaced IngressClasses do not exist' }

    include_examples 'config validation',
                     success_description: 'when set to false',
                     error_description: 'when set to true'
  end
end
