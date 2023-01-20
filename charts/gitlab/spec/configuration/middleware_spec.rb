require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'middleware configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
      global: {}
      gitlab:
        migrations:
          networkpolicy:
            enabled: true
          serviceAccount:
            enabled: true
            create: true
    ))
  end

  context 'When customer provides middleware storage configuration' do
    let(:values) do
      YAML.safe_load(%(
        registry:
          middleware:
            storage:
              - name: cloudfront
                options:
                  baseurl: cdn.registry.example.com
                  privatekeySecret:
                    secret: cdn-private-key
                    key: private.pem
                  keypairid: GIBBERISH
      )).deep_merge(default_values)
    end

    it 'Populates the middleware storage configuration in expected manner' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(
        YAML.safe_load(
          t.dig(
            'ConfigMap/test-registry',
            'data',
            'config.yml'
          ),
          [Symbol]
        )['middleware']).to include(YAML.safe_load(%(
          storage:
            - name: cloudfront
              options:
                baseurl: cdn.registry.example.com
                keypairid: "GIBBERISH"
                privatekey: "/etc/docker/registry/middleware.storage/0/private.pem"
      )))
    end
    it 'Projects middleware storage secrets into deployment' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      projected_secret_key = t.find_projected_secret_key('Deployment/test-registry', 'registry-secrets', 'cdn-private-key', 'private.pem')
      expect(projected_secret_key).to have_key('path')
      expect(projected_secret_key['path']).to eq('middleware.storage/0/private.pem') if projected_secret_key
    end
  end
end
