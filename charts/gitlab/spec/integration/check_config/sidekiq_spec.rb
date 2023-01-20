require 'spec_helper'
require 'check_config_helper'
require 'hash_deep_merge'

describe 'checkConfig sidekiq' do
  describe 'sidekiq.queues.mixed' do
    let(:success_values) do
      YAML.safe_load(%(
        gitlab:
          sidekiq:
            pods:
            - name: valid-1
              queues: merge
            - name: valid-2
              negateQueues: post_receive
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        gitlab:
          sidekiq:
            pods:
            - name: invalid-1
              queues: merge
              negateQueues: post_receive
            - name: invalid-2
              queues: merge
              negateQueues: post_receive
      )).merge(default_required_values)
    end

    let(:error_output) { '`negateQueues` is not usable if `queues` is provided' }

    include_examples 'config validation',
                     success_description: 'when Sidekiq pods use either queues or negateQueues',
                     error_description: 'when Sidekiq pods use both queues and negateQueues'
  end

  describe 'sidekiq.queues' do
    let(:success_values) do
      YAML.safe_load(%(
        gitlab:
          sidekiq:
            pods:
            - name: valid-1
              queues: merge,post_receive
            - name: valid-2
              negateQueues: merge,post_receive
      )).merge(default_required_values)
    end

    let(:error_values) do
      YAML.safe_load(%(
        gitlab:
          sidekiq:
            pods:
            - name: invalid-1
              queues: [merge]
            - name: invalid-2
              negateQueues: [merge]
      )).merge(default_required_values)
    end

    let(:error_output) { 'not a string' }

    include_examples 'config validation',
                     success_description: 'when Sidekiq pods use cluster with string queues',
                     error_description: 'when Sidekiq pods use cluster with array queues'
  end

  describe 'sidekiq.timeout' do
    context 'with deployment-global values specified for both timeout and terminationGracePeriodSeconds and no pod-local values specified for either' do
      let(:success_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              deployment:
                terminationGracePeriodSeconds: 30
              timeout: 10
        )).deep_merge(default_required_values)
      end

      let(:error_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              deployment:
                terminationGracePeriodSeconds: 30
              timeout: 40
        )).deep_merge(default_required_values)
      end

      let(:error_output) { 'You must set `terminationGracePeriodSeconds` (30) longer than `timeout` (40) for pod `all-in-1`.' }

      include_examples 'config validation',
                       success_description: 'when Sidekiq timeout is less than terminationGracePeriodSeconds',
                       error_description: 'when Sidekiq timeout is more than terminationGracePeriodSeconds'
    end

    context 'with pod-local value specified for only timeout' do
      let(:success_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              pods:
                - name: 'valid-1'
                  timeout: 10
        )).deep_merge(default_required_values)
      end

      let(:error_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              pods:
                - name: 'valid-1'
                  timeout: 50
        )).deep_merge(default_required_values)
      end

      let(:error_output) { 'You must set `terminationGracePeriodSeconds` (30) longer than `timeout` (50) for pod `valid-1`.' }

      include_examples 'config validation',
                       success_description: 'when Sidekiq timeout is less than terminationGracePeriodSeconds',
                       error_description: 'when Sidekiq timeout is more than terminationGracePeriodSeconds'
    end

    context 'with pod-local value specified for only terminationGracePeriodSeconds' do
      let(:success_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              pods:
                - name: 'valid-1'
                  terminationGracePeriodSeconds: 50
        )).deep_merge(default_required_values)
      end

      let(:error_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              pods:
                - name: 'valid-1'
                  terminationGracePeriodSeconds: 1
        )).deep_merge(default_required_values)
      end

      let(:error_output) { 'You must set `terminationGracePeriodSeconds` (1) longer than `timeout` (25) for pod `valid-1`.' }

      include_examples 'config validation',
                       success_description: 'when Sidekiq timeout is less than terminationGracePeriodSeconds',
                       error_description: 'when Sidekiq timeout is more than terminationGracePeriodSeconds'
    end

    context 'with pod-local value specified for both terminationGracePeriodSeconds and timeout' do
      let(:success_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              pods:
                - name: 'valid-1'
                  terminationGracePeriodSeconds: 50
                  timeout: 10
        )).deep_merge(default_required_values)
      end

      let(:error_values) do
        YAML.safe_load(%(
          gitlab:
            sidekiq:
              pods:
                - name: 'valid-1'
                  terminationGracePeriodSeconds: 50
                  timeout: 60
        )).deep_merge(default_required_values)
      end

      let(:error_output) { 'You must set `terminationGracePeriodSeconds` (50) longer than `timeout` (60) for pod `valid-1`.' }

      include_examples 'config validation',
                       success_description: 'when Sidekiq timeout is less than terminationGracePeriodSeconds',
                       error_description: 'when Sidekiq timeout is more than terminationGracePeriodSeconds'
    end
  end

  describe 'sidekiq.routingRules' do
    include_context 'check config setup'

    let(:error_output) { 'The Sidekiq\'s routing rules list must be an ordered array of tuples of query and corresponding queue.' }

    context 'with an empty routingRules setting' do
      let(:values) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules: []
        )).deep_merge(default_required_values)
      end

      it 'succeeds' do
        expect(exit_code).to eq(0)
        expect(stdout).to include('name: gitlab-checkconfig-test')
        expect(stderr).to be_empty
      end
    end

    context 'with a valid routingRules setting' do
      let(:values) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules:
                  - ["resource_boundary=cpu", "cpu_boundary"]
                  - ["feature_category=pages", null]
                  - ["feature_category=search", "search"]
                  - ["feature_category=memory|resource_boundary=memory", "memory-bound"]
                  - ["*", "default"]
        )).deep_merge(default_required_values)
      end

      it 'succeeds' do
        expect(exit_code).to eq(0)
        expect(stdout).to include('name: gitlab-checkconfig-test')
        expect(stderr).to be_empty
      end
    end

    context 'a string routingRules setting is a string' do
      let(:values) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules: 'hello'
        )).deep_merge(default_required_values)
      end

      it 'returns an error' do
        expect(exit_code).to be > 0
        expect(stdout).to be_empty
        expect(stderr).to include(error_output)
      end
    end

    context 'one rule is a string' do
      let(:values) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules:
                - ["resource_boundary=cpu", "cpu_boundary"]
                - "feature_category=pages"
        )).deep_merge(default_required_values)
      end

      it 'returns an error' do
        expect(exit_code).to be > 0
        expect(stdout).to be_empty
        expect(stderr).to include(error_output)
      end
    end

    context 'one rule has 0 elements' do
      let(:values) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules:
                - ["resource_boundary=cpu", "cpu_boundary"]
                - []
        )).deep_merge(default_required_values)
      end

      it 'returns an error' do
        expect(exit_code).to be > 0
        expect(stdout).to be_empty
        expect(stderr).to include(error_output)
      end
    end

    context 'one rule has 1 element' do
      let(:values) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules:
                - ["resource_boundary=cpu", "cpu_boundary"]
                - ["hello"]
        )).deep_merge(default_required_values)
      end

      it 'returns an error' do
        expect(exit_code).to be > 0
        expect(stdout).to be_empty
        expect(stderr).to include(error_output)
      end
    end

    context 'one rule has 3 elements' do
      let(:values) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules:
                - ["resource_boundary=cpu", "cpu_boundary"]
                - ["resource_boundary=cpu", "cpu_boundary", "something"]
        )).deep_merge(default_required_values)
      end

      it 'returns an error' do
        expect(exit_code).to be > 0
        expect(stdout).to be_empty
        expect(stderr).to include(error_output)
      end
    end

    context "one rule's queue is invalid" do
      let(:values) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules:
                - ["resource_boundary=cpu", "cpu_boundary"]
                - ["rule", 123]
        )).deep_merge(default_required_values)
      end

      it 'returns an error' do
        expect(exit_code).to be > 0
        expect(stdout).to be_empty
        expect(stderr).to include(error_output)
      end
    end

    context "one rule's query is invalid" do
      let(:values) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules:
                - ["resource_boundary=cpu", "cpu_boundary"]
                - [123, 'valid-queue']
        )).deep_merge(default_required_values)
      end

      it 'returns an error' do
        expect(exit_code).to be > 0
        expect(stdout).to be_empty
        expect(stderr).to include(error_output)
      end
    end
  end
end
