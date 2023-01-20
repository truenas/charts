require 'spec_helper'
require 'check_config_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'checkConfig postgresql' do
  describe 'database.externaLoadBalancing' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          psql:
            host: primary
            password:
              secret: bar
            load_balancing:
              hosts: [a, b, c]
        postgresql:
          install: false
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          psql:
            host: primary
            password:
              secret: bar
            load_balancing:
              hosts: [a, b, c]
        postgresql:
          install: true
      )).merge(default_required_values)
    end

    let(:error_output) { 'PostgreSQL is set to install, but database load balancing is also enabled' }

    include_examples 'config validation',
                     success_description: 'when database load balancing is configured, with PostgrSQL disabled',
                     error_description: 'when database load balancing is configured, with PostgrSQL enabled'

    describe 'database.externaLoadBalancing missing required elements' do
      let(:success_values) do
        YAML.safe_load(%(
          global:
            psql:
              host: primary
              password:
                secret: bar
              load_balancing:
                hosts: [a, b, c]
          postgresql:
            install: false
        )).merge(default_required_values)
      end

      let(:error_values) do
        YAML.safe_load(%(
          global:
            psql:
              host: primary
              password:
                secret: bar
              load_balancing:
                invalid: item
          postgresql:
            install: false
        )).merge(default_required_values)
      end

      let(:error_output) { 'You must specify `load_balancing.hosts` or `load_balancing.discover`' }

      include_examples 'config validation',
                       success_description: 'when database load balancing is configured per requirements',
                       error_description: 'when database load balancing is missing required elements'
    end

    describe 'database.externaLoadBalancing.hosts' do
      let(:success_values) do
        YAML.safe_load(%(
          global:
            psql:
              host: primary
              password:
                secret: bar
              load_balancing:
                hosts: [a, b, c]
          postgresql:
            install: false
        )).merge(default_required_values)
      end

      let(:error_values) do
        YAML.safe_load(%(
          global:
            psql:
              host: primary
              password:
                secret: bar
              load_balancing:
                hosts: a
          postgresql:
            install: false
        )).merge(default_required_values)
      end

      let(:error_output) { 'Database load balancing using `hosts` is configured, but does not appear to be a list' }

      include_examples 'config validation',
                       success_description: 'when database load balancing is configured for hosts, with an array',
                       error_description: 'when database load balancing is configured for hosts, without an array'
    end

    describe 'database.externaLoadBalancing.discover' do
      let(:success_values) do
        YAML.safe_load(%(
          global:
            psql:
              host: primary
              password:
                secret: bar
              load_balancing:
                discover:
                  record: secondary
          postgresql:
            install: false
        )).merge(default_required_values)
      end

      let(:error_values) do
        YAML.safe_load(%(
          global:
            psql:
              host: primary
              password:
                secret: bar
              load_balancing:
                discover: true
          postgresql:
            install: false
        )).merge(default_required_values)
      end

      let(:error_output) { 'Database load balancing using `discover` is configured, but does not appear to be a map' }

      include_examples 'config validation',
                       success_description: 'when database load balancing is configured for discover, with a map',
                       error_description: 'when database load balancing is configured for discover, without a map'
    end
  end

  describe 'PostgreSQL version' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 12
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 11
      )).merge(default_required_values)
    end

    let(:error_output) { 'The minimum required version is PostgreSQL 12.' }

    include_examples 'config validation',
                     success_description: 'when postgresql.image.tag is >= 12',
                     error_description: 'when postgresql.image.tag is < 12'
  end
end
