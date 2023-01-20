require 'spec_helper'
require 'check_config_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'checkConfig registry' do
  describe 'registry.database (PG version)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 12

        registry:
          database:
            enabled: true
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 11

        registry:
          database:
            enabled: true
      )).merge(default_required_values)
    end

    let(:error_output) { 'PostgreSQL 12 is the minimum required version' }

    include_examples 'config validation',
                     success_description: 'when postgresql.image.tag is >= 12',
                     error_description: 'when postgresql.image.tag is < 12'
  end

  describe 'registry.database (sslmode)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 12

        registry:
          database:
            enabled: true
            sslmode: disable
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 12

        registry:
          database:
            enabled: true
            sslmode: testing
      )).merge(default_required_values)
    end

    let(:error_output) { 'Invalid SSL mode' }

    include_examples 'config validation',
                     success_description: 'when database.sslmode is valid',
                     error_description: 'when when database.sslmode is not valid'
  end

  describe 'registry.migration (disablemirrorfs)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 12

        registry:
          database:
            enabled: true
          migration:
            disablemirrorfs: true
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 12

        registry:
          migration:
            disablemirrorfs: true
      )).merge(default_required_values)
    end

    let(:error_output) { 'Disabling filesystem metadata requires the metadata database to be enabled' }

    include_examples 'config validation',
                     success_description: 'when migration disablemirrorfs is true, with database enabled',
                     error_description: 'when migration disablemirrorfs is true, with database disabled'
  end

  describe 'registry.migration (enabled)' do
    let(:success_values) do
      YAML.safe_load(%(
        registry:
          database:
            enabled: true
          migration:
            enabled: true
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        registry:
          migration:
            enabled: true
      )).merge(default_required_values)
    end

    let(:error_output) { 'Enabling migration mode requires the metadata database to be enabled' }

    include_examples 'config validation',
                     success_description: 'when migration enabled is true, with database enabled',
                     error_description: 'when migration enabled is true, with database disabled'
  end

  describe 'registry.gc (disabled)' do
    let(:success_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 12

        registry:
          database:
            enabled: true
          gc:
            disabled: false
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        postgresql:
          image:
            tag: 12

        registry:
          gc:
            disabled: false
      )).merge(default_required_values)
    end

    let(:error_output) { 'Enabling online garbage collection requires the metadata database to be enabled' }

    include_examples 'config validation',
                     success_description: 'when gc disabled is false, with database enabled',
                     error_description: 'when gc disabled is false, with database disabled'
  end

  describe 'gitlab.checkConfig.registry.sentry.dsn' do
    let(:success_values) do
      YAML.safe_load(%(
        registry:
          reporting:
            sentry:
              enabled: true
              dsn: somedsn
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        registry:
          reporting:
            sentry:
              enabled: true
      )).merge(default_required_values)
    end

    let(:error_output) { 'When enabling sentry, you must configure at least one DSN.' }

    include_examples 'config validation',
                     success_description: 'when Sentry is enabled and DSN is defined',
                     error_description: 'when Sentry is enabled but DSN is undefined'
  end
end
