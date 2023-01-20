require 'spec_helper'
require 'check_config_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'checkConfig gitaly' do
  describe 'gitaly.tls without Praefect' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          gitaly:
            enabled: true
            tls:
              enabled: true
              secretName: example-tls
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          gitaly:
            enabled: true
            tls:
              enabled: true
      )).merge(default_required_values)
    end

    let(:error_output) { 'global.gitaly.tls.secretName not specified' }

    include_examples 'config validation',
                     success_description: 'when TLS is enabled correctly',
                     error_description: 'when TLS is enabled but there is no certificate'
  end

  describe 'gitaly.tls with Praefect' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          praefect:
            enabled: true
            virtualStorages:
            - name: default
              gitalyReplicas: 3
              maxUnavailable: 2
              tlsSecretName: gitaly-default-tls
            - name: vs1
              gitalyReplicas: 2
              maxUnavailable: 1
              tlsSecretName: gitaly-vs2-tls
          gitaly:
            enabled: true
            tls:
              enabled: true
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          praefect:
            enabled: true
            virtualStorages:
            - name: default
              gitalyReplicas: 3
              maxUnavailable: 2
              tlsSecretName: gitaly-default-tls
            - name: vs2
              gitalyReplicas: 2
              maxUnavailable: 1
          gitaly:
            enabled: true
            tls:
              enabled: true
      )).merge(default_required_values)
    end

    let(:error_output) { 'global.praefect.virtualStorages[1].tlsSecretName not specified (\'vs2\')' }

    include_examples 'config validation',
                     success_description: 'when TLS is enabled correctly',
                     error_description: 'when TLS is enabled but there is no certificate'
  end

  describe 'gitaly.extern.repos' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          gitaly:
            enabled: false
            external:
            - name: default
              hostname: bar
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          gitaly:
            enabled: false
            external: []
      )).merge(default_required_values)
    end

    let(:error_output) { 'external Gitaly repos needs to be specified if global.gitaly.enabled is not set' }

    include_examples 'config validation',
                     success_description: 'when Gitaly is disabled and external repos are enabled',
                     error_description: 'when Gitaly and external repos are disabled'
  end

  describe 'gitaly.duplicate.repos' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          gitaly:
            internal:
              names:
              - default
            external:
              - name: foo
                hostname: bar
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          gitaly:
            internal:
              names:
              - default
              - foo
            external:
              - name: foo
                hostname: bar
      )).merge(default_required_values)
    end

    let(:error_output) { 'Each storage name must be unique.' }

    include_examples 'config validation',
                     success_description: 'when Gitaly is enabled and storage names are unique',
                     error_description: 'when Gitaly is enabled and storage names are not unique'
  end

  describe 'gitaly.duplicate.repos with praefect' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          gitaly:
            internal:
              names:
              - default
              - foo
          praefect:
            enabled: true
            replaceInternalGitaly: false
            virtualStorages:
            - name: defaultPraefect
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          gitaly:
            internal:
              names:
              - default
              - foo
          praefect:
            enabled: true
            replaceInternalGitaly: false
            virtualStorages:
            - name: foo
      )).merge(default_required_values)
    end

    let(:error_output) { 'Each storage name must be unique.' }

    include_examples 'config validation',
                     success_description: 'when Gitaly and Praefect are enabled and storage names are unique',
                     error_description: 'when Gitaly and Praefect are enabled and storage names are not unique'
  end

  describe 'gitaly.default.repo' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          gitaly:
            internal:
              names:
              - default
            external:
              - name: external1
                hostname: foo
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          gitaly:
            internal:
              names:
              - foo
            external:
              - name: bar
                hostname: baz
      )).merge(default_required_values)
    end

    let(:error_output) { 'There must be one (and only one) storage named \'default\'.' }

    include_examples 'config validation',
                     success_description: 'when Gitaly is enabled and one storage is named "default"',
                     error_description: 'when Gitaly is enabled and no storages are named "default"'
  end

  describe 'gitaly.default.repo with praefect' do
    let(:success_values) do
      YAML.safe_load(%(
        global:
          gitaly:
            internal:
              names:
                - default
            external:
              - name: external1
                hostname: foo
          praefect:
            enabled: true
            replaceInternalGitaly: false
            virtualStorages:
            - name: praefect1
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        global:
          gitaly:
            internal:
              names:
                - internal1
            external:
              - name: external1
                hostname: baz
          praefect:
            enabled: true
            replaceInternalGitaly: false
            virtualStorages:
            - name: praefect1
      )).merge(default_required_values)
    end

    let(:error_output) { 'There must be one (and only one) storage named \'default\'.' }

    include_examples 'config validation',
                     success_description: 'when Gitaly and Praefect are enabled and one storage is named "default"',
                     error_description: 'when Gitaly and Praefect are enabled and no storages are named "default"'
  end
end
