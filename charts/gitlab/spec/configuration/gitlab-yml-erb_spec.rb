require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'gitlab.yml.erb configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
    ))
  end

  context 'when CSP is disabled' do
    it 'does not populate the gitlab.yml.erb' do
      t = HelmTemplate.new(default_values)
      expect(t.dig(
        'ConfigMap/test-webservice',
        'data',
        'gitlab.yml.erb'
      )).not_to include('content_security_policy')
    end
  end

  context 'when CSP is enabled' do
    let(:required_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            contentSecurityPolicy:
              enabled: true
              report_only: false
              directives:
                connect_src: "'self'"
                frame_ancestors: "'self'"
                frame_src: "'self'"
                img_src: "* data: blob:"
                object_src: "'none'"
                script_src: "'self' 'unsafe-inline' 'unsafe-eval'"
                style_src: "'self'"
      )).merge(default_values)
    end

    let(:missing_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            contentSecurityPolicy:
              enabled: true
      )).merge(default_values)
    end

    it 'populates the gitlab.yml.erb' do
      t = HelmTemplate.new(required_values)
      expect(t.dig(
        'ConfigMap/test-webservice',
        'data',
        'gitlab.yml.erb'
      )).to include('content_security_policy')
    end

    it 'fails when we are missing a required value' do
      t = HelmTemplate.new(missing_values)
      expect(t.exit_code).not_to eq(0)
      expect(t.stderr).to include(
        'set `global.appConfig.contentSecurityPolicy.directives'
      )
    end
  end

  context 'matomoDisableCookies' do
    let(:required_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            extra:
              matomoDisableCookies: #{value}
      )).merge(default_values)
    end

    context 'when true' do
      let(:value) { true }

      it 'populates the gitlab.yml.erb with true' do
        t = HelmTemplate.new(required_values)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).to include('matomo_disable_cookies: true')
      end
    end

    context 'when false' do
      let(:value) { false }

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).not_to include('matomo_disable_cookies')
      end
    end

    context 'when nil' do
      let(:value) { nil }

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).not_to include('matomo_disable_cookies')
      end
    end
  end

  context 'oneTrustId' do
    let(:required_values) do
      YAML.safe_load(%(
        global:
          appConfig:
            extra:
              oneTrustId: #{value}
      )).merge(default_values)
    end

    context 'when configured' do
      let(:value) { 'foo' }

      it 'populates the gitlab.yml.erb with id' do
        t = HelmTemplate.new(required_values)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).to include('one_trust_id: "foo"')
      end
    end

    context 'when not configured' do
      let(:value) { nil }

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(t.dig(
          'ConfigMap/test-webservice',
          'data',
          'gitlab.yml.erb'
        )).not_to include('one_trust_id')
      end
    end
  end

  context 'sidekiq.routingRules on web' do
    let(:required_values) do
      value.merge(default_values)
    end

    context 'when empty array' do
      let(:value) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules: []
        ))
      end

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.stderr).to eq("")
        expect(t.exit_code).to eq(0)
        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-webservice',
            'data',
            'gitlab.yml.erb'
          )
        )['production']).to have_key('sidekiq')
      end
    end

    context 'when an array of tuples' do
      let(:value) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules:
                  - ["resource_boundary=cpu", "cpu_boundary"]
                  - ["feature_category=pages", null]
                  - ["feature_category=search", '']
                  - ["feature_category=memory|resource_boundary=memory", 'memory']
                  - ["*", "default"]
        ))
      end

      it 'populates the gitlab.yml.erb with corresponding array' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-webservice',
            'data',
            'gitlab.yml.erb'
          )
        )['production']).to include(YAML.safe_load(%(
          sidekiq:
            routing_rules:
              - ["resource_boundary=cpu","cpu_boundary"]
              - ["feature_category=pages",null]
              - ["feature_category=search",""]
              - ["feature_category=memory|resource_boundary=memory","memory"]
              - ["*","default"]
        )))
      end
    end
  end

  context 'sidekiq.routingRules on Sidekiq' do
    let(:required_values) do
      value.merge(default_values)
    end

    context 'when empty array' do
      let(:value) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules: []
        ))
      end

      it 'does not populate the gitlab.yml.erb' do
        t = HelmTemplate.new(required_values)

        expect(t.stderr).to eq("")
        expect(t.exit_code).to eq(0)
        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-sidekiq',
            'data',
            'gitlab.yml.erb'
          )
        )['production']['sidekiq']).to include(YAML.safe_load(%(
          log_format: "default"
        )))
      end
    end

    context 'when an array of tuples' do
      let(:value) do
        YAML.safe_load(%(
          global:
            appConfig:
              sidekiq:
                routingRules:
                  - ["resource_boundary=cpu", "cpu_boundary"]
                  - ["feature_category=pages", null]
                  - ["feature_category=search", '']
                  - ["feature_category=memory|resource_boundary=memory", 'memory']
                  - ["*", "default"]
        ))
      end

      it 'populates the gitlab.yml.erb with corresponding array' do
        t = HelmTemplate.new(required_values)

        expect(t.exit_code).to eq(0)
        expect(YAML.safe_load(
          t.dig(
            'ConfigMap/test-sidekiq',
            'data',
            'gitlab.yml.erb'
          )
        )['production']['sidekiq']).to include(YAML.safe_load(%(
          log_format: "default"
          routing_rules:
            - ["resource_boundary=cpu","cpu_boundary"]
            - ["feature_category=pages",null]
            - ["feature_category=search",""]
            - ["feature_category=memory|resource_boundary=memory","memory"]
            - ["*","default"]
        )))
      end
    end
  end
end
