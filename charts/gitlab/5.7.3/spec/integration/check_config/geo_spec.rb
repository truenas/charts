require 'spec_helper'
require 'check_config_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'checkConfig geo' do
  describe 'geo.database' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          geo:
            enabled: true
          psql:
            host: foo
            password:
              secret: bar
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          geo:
            enabled: true
      )).merge(default_required_values)
    end

    let(:error_output) { 'Geo was configured but no database was provided' }

    include_examples 'config validation',
                     success_description: 'when Geo is enabled with a database',
                     error_description: 'when Geo is enabled without a database'
  end

  describe 'geo.secondary.database' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          geo:
            enabled: true
          psql:
            host: foo
            password:
              secret: bar
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          geo:
            enabled: true
            role: secondary
          psql:
            host: foo
            password:
              secret: bar
      )).merge(default_required_values)
    end

    let(:error_output) { 'Geo was configured with `role: secondary`, but no database was provided' }

    include_examples 'config validation',
                     success_description: 'when Geo is enabled with a database',
                     error_description: 'when Geo is enabled without a database'
  end

  describe 'geo.replication.primaryApiUrl' do
    let(:success_values) do
      {
        'global' => {
          'geo' => {
            'enabled' => true,
            'registry' => {
              'replication' => {
                'enabled' => true,
                'primaryApiUrl' => 'http://registry.foobar.com'
              }
            }
          },
          'psql' => { 'host' => 'foo', 'password' => { 'secret' => 'bar' } }
        }
      }.merge(default_required_values)
    end

    let(:error_values) do
      {
        'global' => {
          'geo' => {
            'enabled' => true,
            'role' => 'secondary',
            'registry' => {
              'replication' => {
                'enabled' => true
              }
            }
          },
          'psql' => { 'host' => 'foo', 'password' => { 'secret' => 'bar' } }
        }
      }.merge(default_required_values)
    end

    let(:error_output) { 'Registry replication is enabled for GitLab Geo, but no primary API URL is specified.' }

    include_examples 'config validation',
                     success_description: 'when Registry replication is enabled for Geo and primary API URL is specified',
                     error_description: 'when Registry replication is enabled for Geo but no primary API URL is specified'
  end
end
