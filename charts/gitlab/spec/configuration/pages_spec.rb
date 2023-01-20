# frozen_string_literal: true

require 'spec_helper'
require 'hash_deep_merge'
require 'helm_template_helper'
require 'yaml'

describe 'GitLab Pages' do
  let(:values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
    ))
  end

  let(:required_resources) do
    %w[Deployment ConfigMap Ingress Service HorizontalPodAutoscaler PodDisruptionBudget]
  end

  describe 'pages is disabled by default' do
    it 'does not create any pages related resource' do
      template = HelmTemplate.new(values)

      required_resources.each do |resource|
        resource_name = "#{resource}/test-gitlab-pages"

        expect(template.resources_by_kind(resource)[resource_name]).to be_nil
      end
    end
  end

  context 'when pages is enabled' do
    let(:pages_enabled_values) do
      YAML.safe_load(%(
        global:
          pages:
            enabled: true
      ))
    end

    let(:pages_enabled_template) do
      HelmTemplate.new(values.merge(pages_enabled_values))
    end

    it 'creates all pages related required_resources' do
      required_resources.each do |resource|
        resource_name = "#{resource}/test-gitlab-pages"

        expect(pages_enabled_template.resources_by_kind(resource)[resource_name]).to be_kind_of(Hash)
      end
    end

    describe 'when network policy is enabled' do
      let(:enable_network_policy) do
        YAML.safe_load(%(
          gitlab:
            gitlab-pages:
              networkpolicy:
                enabled: true
        )).deep_merge(pages_enabled_values).deep_merge(values)
      end

      it 'creates a network policy object' do
        t = HelmTemplate.new(enable_network_policy)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        expect(t.dig('NetworkPolicy/test-gitlab-pages-v1', 'metadata', 'labels')).to include('app' => 'gitlab-pages')
      end
    end

    context 'When customer provides additional labels' do
      let(:labels) do
        YAML.safe_load(%(
          global:
            common:
              labels:
                global: global
                foo: global
            pod:
              labels:
                global_pod: true
            service:
              labels:
                global_service: true
          gitlab:
            gitlab-pages:
              common:
                labels:
                  global: pages
                  pages: pages
              podLabels:
                pod: true
                global: pod
              serviceAccount:
                create: true
                enabled: true
              serviceLabels:
                service: true
                global: service
        )).deep_merge(pages_enabled_values.deep_merge(values))
      end

      it 'Populates the additional labels in the expected manner' do
        t = HelmTemplate.new(labels)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        expect(t.dig('ConfigMap/test-gitlab-pages', 'metadata', 'labels')).to include('global' => 'pages')
        expect(t.dig('Deployment/test-gitlab-pages', 'metadata', 'labels')).to include('foo' => 'global')
        expect(t.dig('Deployment/test-gitlab-pages', 'metadata', 'labels')).to include('global' => 'pages')
        expect(t.dig('Deployment/test-gitlab-pages', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(t.dig('Deployment/test-gitlab-pages', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
        expect(t.dig('Deployment/test-gitlab-pages', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
        expect(t.dig('Deployment/test-gitlab-pages', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
        expect(t.dig('HorizontalPodAutoscaler/test-gitlab-pages', 'metadata', 'labels')).to include('global' => 'pages')
        expect(t.dig('Ingress/test-gitlab-pages', 'metadata', 'labels')).to include('global' => 'pages')
        expect(t.dig('PodDisruptionBudget/test-gitlab-pages', 'metadata', 'labels')).to include('global' => 'pages')
        expect(t.dig('Service/test-gitlab-pages', 'metadata', 'labels')).to include('global' => 'service')
        expect(t.dig('Service/test-gitlab-pages', 'metadata', 'labels')).to include('global_service' => 'true')
        expect(t.dig('Service/test-gitlab-pages', 'metadata', 'labels')).to include('service' => 'true')
        expect(t.dig('Service/test-gitlab-pages', 'metadata', 'labels')).not_to include('global' => 'global')
        expect(t.dig('ServiceAccount/test-gitlab-pages', 'metadata', 'labels')).to include('global' => 'pages')
      end
    end

    describe 'API secret key' do
      context 'when not explicitly provided by user' do
        it 'creates necessary secrets and mounts them on webservice deployment' do
          webservice_secret_mounts = pages_enabled_template.projected_volume_sources(
            'Deployment/test-webservice-default',
            'init-webservice-secrets'
          )

          shared_secret_mount = webservice_secret_mounts.select do |item|
            item['secret']['name'] == 'test-gitlab-pages-secret' && item['secret']['items'][0]['key'] == 'shared_secret'
          end

          expect(shared_secret_mount.length).to eq(1)
        end

        it 'creates necessary secrets and mounts them on pages deployment' do
          pages_secret_mounts = pages_enabled_template.projected_volume_sources(
            'Deployment/test-gitlab-pages',
            'init-pages-secrets'
          )

          shared_secret_mount = pages_secret_mounts.select do |item|
            item.dig('secret', 'name') == 'test-gitlab-pages-secret' && item.dig('secret', 'items', 0, 'key') == 'shared_secret'
          end

          expect(shared_secret_mount.length).to eq(1)
        end
      end

      context 'when API secrets are provided by user' do
        let(:custom_secret_key) { 'pages_custom_secret_key' }
        let(:custom_secret_name) { 'pages_custom_secret_name' }

        let(:pages_enabled_values) do
          YAML.safe_load(%(
            global:
              pages:
                enabled: true
                apiSecret:
                  secret: #{custom_secret_name}
                  key: #{custom_secret_key}
          ))
        end

        it 'mounts shared secret on webservice deployment' do
          webservice_secret_mounts = pages_enabled_template.projected_volume_sources(
            'Deployment/test-webservice-default',
            'init-webservice-secrets'
          )

          shared_secret_mount = webservice_secret_mounts.select do |item|
            item['secret']['name'] == custom_secret_name && item['secret']['items'][0]['key'] == custom_secret_key
          end

          expect(shared_secret_mount.length).to eq(1)
        end

        it 'mounts shared secret on pages deployment' do
          pages_secret_mounts = pages_enabled_template.projected_volume_sources(
            'Deployment/test-gitlab-pages',
            'init-pages-secrets'
          )

          shared_secret_mount = pages_secret_mounts.select do |item|
            item.dig('secret', 'name') == custom_secret_name && item.dig('secret', 'items', 0, 'key') == custom_secret_key
          end

          expect(shared_secret_mount.length).to eq(1)
        end
      end
    end

    describe 'GitLab yml file contents' do
      subject(:config_yaml_data) do
        YAML.safe_load(pages_enabled_template.dig('ConfigMap/test-webservice', 'data', 'gitlab.yml.erb'))
      end

      context 'with default values' do
        it 'populates Pages configuration' do
          expect(pages_enabled_template.exit_code).to eq(0), "Unexpected error code #{pages_enabled_template.exit_code} -- #{pages_enabled_template.stderr}"
          expect(config_yaml_data['production']['pages']).to eq(
            'enabled' => true,
            'access_control' => false,
            'artifacts_server' => true,
            'path' => '/srv/gitlab/shared/pages',
            'host' => 'pages.example.com',
            'port' => 443,
            'external_http' => false,
            'external_https' => false,
            'https' => true,
            'secret_file' => '/etc/gitlab/pages/secret',
            'object_store' => {
              'enabled' => true,
              'remote_directory' => 'gitlab-pages',
              'connection' => {
                'provider' => 'AWS',
                'region' => 'us-east-1',
                'host' => 'minio.example.com',
                'endpoint' => 'http://test-minio-svc.default.svc:9000',
                'path_style' => true,
                'aws_access_key_id' => "<%= File.read('/etc/gitlab/minio/accesskey').strip.to_json %>",
                'aws_secret_access_key' => "<%= File.read('/etc/gitlab/minio/secretkey').strip.to_json %>"
              }
            },
            'local_store' => {
              'enabled' => false,
              'path' => nil
            }
          )
        end
      end

      context 'with user specified values' do
        let(:pages_enabled_values) do
          YAML.safe_load(%(
            global:
              pages:
                enabled: true
                accessControl: true
                path: /srv/foobar
                host: mycustompages.com
                port: 123
                https: false
                externalHttp: ['1.2.3.4']
                externalHttps: ['1.2.3.4']
                artifactsServer: false
                objectStore:
                  enabled: true
                  bucket: random-bucket
                  connection:
                    secret: custom-secret
                    key: custom-key
                localStore:
                  enabled: true
                  path: /random/path
          ))
        end

        it 'populates Pages configuration' do
          expect(config_yaml_data['production']['pages']).to eq(
            'enabled' => true,
            'access_control' => true,
            'artifacts_server' => false,
            'path' => '/srv/foobar',
            'host' => 'mycustompages.com',
            'port' => 123,
            'external_http' => true,
            'external_https' => true,
            'https' => false,
            'secret_file' => '/etc/gitlab/pages/secret',
            'object_store' => {
              'enabled' => true,
              'remote_directory' => 'random-bucket',
              'connection' => "<%= YAML.load_file(\"/etc/gitlab/objectstorage/pages\").to_json() %>"
            },
            'local_store' => {
              'enabled' => true,
              'path' => '/random/path'
            }
          )
        end

        describe 'access control' do
          it 'creates necessary secrets and configmaps and mounts them on migration job' do
            migrations_secret_mounts = pages_enabled_template.projected_volume_sources(
              'Job/test-migrations-1',
              'init-migrations-secrets'
            )

            oauth_secret_mount = migrations_secret_mounts.select do |item|
              item.key?('secret') && \
                item['secret']['name'] == 'test-oauth-gitlab-pages-secret' && \
                item['secret']['items'][0]['key'] == 'appid' &&  \
                item['secret']['items'][0]['path'] == 'oauth-secrets/gitlab-pages/appid' &&  \
                item['secret']['items'][1]['key'] == 'appsecret' && \
                item['secret']['items'][1]['path'] == 'oauth-secrets/gitlab-pages/appsecret'
            end

            oauth_configmap_mount = migrations_secret_mounts.select do |item|
              item.key?('configMap') && \
                item['configMap']['name'] == 'test-migrations' && \
                item['configMap']['items'][0]['key'] == 'pages_redirect_uri' && \
                item['configMap']['items'][0]['path'] == 'oauth-secrets/gitlab-pages/redirecturi'
            end

            expect(oauth_secret_mount.length).to eq(1)
            expect(oauth_configmap_mount.length).to eq(1)
          end

          it 'creates necessary secrets and mounts them on pages deployment' do
            pages_secret_mounts = pages_enabled_template.projected_volume_sources(
              'Deployment/test-gitlab-pages',
              'init-pages-secrets'
            )

            shared_secret_mount = pages_secret_mounts.select do |item|
              item['secret']['name'] == 'test-oauth-gitlab-pages-secret' && \
                item['secret']['items'][0]['key'] == 'appid' &&  \
                item['secret']['items'][0]['path'] == 'pages/gitlab_appid' &&  \
                item['secret']['items'][1]['key'] == 'appsecret' && \
                item['secret']['items'][1]['path'] == 'pages/gitlab_appsecret'
            end

            expect(shared_secret_mount.length).to eq(1)
          end
        end
      end

      describe 'https' do
        context 'by default' do
          let(:pages_enabled_values) do
            YAML.safe_load(%(
              global:
                pages:
                  enabled: true
            ))
          end

          it 'sets value for https setting in config file correctly' do
            expect(config_yaml_data['production']['pages']['https']).to be true
          end
        end

        context 'when global.pages.https is set' do
          let(:pages_enabled_values) do
            YAML.safe_load(%(
              global:
                pages:
                  enabled: true
                  https: false
            ))
          end

          it 'sets value for https setting in config file correctly' do
            expect(config_yaml_data['production']['pages']['https']).to be false
          end
        end

        context 'when global.hosts.pages.https is set' do
          let(:pages_enabled_values) do
            YAML.safe_load(%(
              global:
                hosts:
                  pages:
                    https: false
                pages:
                  enabled: true
            ))
          end

          it 'sets value for https setting in config file correctly' do
            expect(config_yaml_data['production']['pages']['https']).to be false
          end
        end

        context 'when global.hosts.https is set' do
          let(:pages_enabled_values) do
            YAML.safe_load(%(
              global:
                hosts:
                  https: false
                pages:
                  enabled: true
            ))
          end

          it 'sets value for https setting in config file correctly' do
            expect(config_yaml_data['production']['pages']['https']).to be false
          end
        end

        context 'when global.pages.https and global.hosts.https are set' do
          let(:pages_enabled_values) do
            YAML.safe_load(%(
              global:
                hosts:
                  https: true
                pages:
                  enabled: true
                  https: false
            ))
          end

          it 'value from global.pages.https is used in config file' do
            expect(config_yaml_data['production']['pages']['https']).to be false
          end
        end
      end
    end

    describe 'Pages configuration file' do
      subject(:config_data) do
        pages_enabled_template.dig('ConfigMap/test-gitlab-pages', 'data', 'config.tpl')
      end

      context 'default values with Pages enabled' do
        let(:pages_enabled_values) do
          YAML.safe_load(%(
            global:
              pages:
                enabled: true
          ))
        end

        it 'populates Pages config file' do
          default_content = <<~MSG
            listen-proxy=0.0.0.0:8090
            listen-http=0.0.0.0:9090
            pages-domain=pages.example.com
            pages-root=/srv/gitlab-pages
            log-format=json
            log-verbose=false
            redirect-http=false
            use-http2=true
            insecure-ciphers=false
            artifacts-server=http://test-webservice-default.default.svc:8181/api/v4
            artifacts-server-timeout=10
            gitlab-server=https://gitlab.example.com
            internal-gitlab-server=http://test-webservice-default.default.svc:8181
            api-secret-key=/etc/gitlab-secrets/pages/secret
            domain-config-source=gitlab
            metrics-address=:9235
            pages-status=/-/readiness
          MSG

          expect(config_data).to eq default_content
        end
      end

      context 'with custom values' do
        let(:pages_enabled_values) do
          YAML.safe_load(%(
            global:
              pages:
                enabled: true
                accessControl: true
            gitlab:
              gitlab-pages:
                artifactsServerTimeout: 50
                artifactsServerUrl: https://randomwebsite.com
                domainConfigSource: disk
                gitlabClientHttpTimeout: 25
                gitlabClientJwtExpiry: 35
                gitlabRetrieval:
                  retries: 3
                gitlabServer: https://randomgitlabserver.com
                headers:
                  - "FOO: BAR"
                  - "BAZ: BAT"
                insecureCiphers: true
                internalGitlabServer: https://int.randomgitlabserver.com
                logFormat: text
                logVerbose: true
                maxConnections: 45
                maxURILength: 2048
                redirectHttp: true
                sentry:
                  enabled: true
                  dsn: foobar
                  environment: qwerty
                tls:
                  minVersion: tls1.0
                  maxVersion: tls1.2
                useHttp2: false
                metrics:
                  port: 9999
                zipCache:
                  refresh: 60s
                rateLimitSourceIP: 100.5
                rateLimitSourceIPBurst: 50
                rateLimitDomain: 2000.5
                rateLimitDomainBurst: 20000
          ))
        end

        it 'populates Pages configuration' do
          default_content = <<~MSG
            gitlab-retrieval-retries=3
            header=FOO: BAR;;BAZ: BAT
            listen-proxy=0.0.0.0:8090
            listen-http=0.0.0.0:9090
            pages-domain=pages.example.com
            pages-root=/srv/gitlab-pages
            log-format=text
            log-verbose=true
            redirect-http=true
            use-http2=false
            insecure-ciphers=true
            artifacts-server=https://randomwebsite.com
            artifacts-server-timeout=50
            gitlab-server=https://randomgitlabserver.com
            internal-gitlab-server=https://int.randomgitlabserver.com
            api-secret-key=/etc/gitlab-secrets/pages/secret
            domain-config-source=disk
            metrics-address=:9999
            max-conns=45
            max-uri-length=2048
            gitlab-client-http-timeout=25
            gitlab-client-jwt-expiry=35
            sentry-dsn=foobar
            sentry-environment=qwerty
            pages-status=/-/readiness
            tls-min-version=tls1.0
            tls-max-version=tls1.2
            auth-redirect-uri=https://projects.pages.example.com/auth
            auth-client-id={% file.Read "/etc/gitlab-secrets/pages/gitlab_appid" %}
            auth-client-secret={% file.Read "/etc/gitlab-secrets/pages/gitlab_appsecret" %}
            auth-secret={% file.Read "/etc/gitlab-secrets/pages/auth_secret" %}
            zip-cache-refresh=60s
            rate-limit-source-ip=100.5
            rate-limit-source-ip-burst=50
            rate-limit-domain=2000.5
            rate-limit-domain-burst=20000
          MSG

          expect(pages_enabled_template.exit_code).to eq(0), "Unexpected error code #{pages_enabled_template.exit_code} -- #{pages_enabled_template.stderr}"
          expect(config_data).to eq default_content
        end
      end
    end

    describe 'customDomains' do
      subject(:gitlab_yml_data) do
        YAML.safe_load(pages_enabled_template.dig('ConfigMap/test-webservice', 'data', 'gitlab.yml.erb'))
      end

      subject(:pages_config_data) do
        pages_enabled_template.dig('ConfigMap/test-gitlab-pages', 'data', 'config.tpl')
      end

      context 'when not enabled' do
        describe 'gitlab.yml file' do
          it 'sets externalHTTP and externalHTTPS to false' do
            expect(gitlab_yml_data['production']['pages']['external_http']).to be false
            expect(gitlab_yml_data['production']['pages']['external_https']).to be false
          end
        end

        describe 'pages configuration' do
          it 'does not expose listen-https, root-cert or root-key' do
            expect(pages_config_data).not_to match(/listen-https=/)
            expect(pages_config_data).not_to match(/root-cert=/)
            expect(pages_config_data).not_to match(/root-key=/)
          end

          it 'exposes listen-proxy correctly' do
            expect(pages_config_data).to match(/listen-proxy=0.0.0.0:8090/)
          end

          it 'configures readiness probe correctly' do
            expect(pages_config_data).to match(/listen-http=0.0.0.0:9090/)
            expect(pages_config_data).to match(%r{pages-status=/-/readiness})
          end
        end

        describe 'pages-custom-domain service' do
          it 'is not enabled' do
            expect(pages_enabled_template.dig('Service/test-gitlab-pages-custom-domains')).to be nil
          end
        end

        describe 'pages TLS secret' do
          it 'is not mounted on Pages pod' do
            pages_secret_mounts = pages_enabled_template.projected_volume_sources(
              'Deployment/test-gitlab-pages',
              'init-pages-secrets'
            )

            tls_mount = pages_secret_mounts.find { |mount| mount['secret']['name'] == 'test-pages-tls' }

            expect(tls_mount).to be_nil
          end
        end
      end

      context 'when only HTTP custom domains are enabled' do
        let(:pages_enabled_values) do
          YAML.safe_load(%(
            global:
              pages:
                enabled: true
                externalHttp: ['1.2.3.4']
          ))
        end

        describe 'gitlab.yml file' do
          it 'sets externalHTTP to true and externalHTTPS to false' do
            expect(gitlab_yml_data['production']['pages']['external_http']).to be true
            expect(gitlab_yml_data['production']['pages']['external_https']).to be false
          end
        end

        describe 'pages configuration' do
          it 'does not expose listen-https or root-cert or root-key' do
            expect(pages_config_data).not_to match(/listen-https=/)
            expect(pages_config_data).not_to match(/root-cert=/)
            expect(pages_config_data).not_to match(/root-key=/)
          end

          it 'does not expose listen-proxy ' do
            expect(pages_config_data).not_to match(/listen-proxy=/)
          end

          it 'exposes listen-http correctly' do
            expect(pages_config_data).to match(/listen-http=0.0.0.0:8090/)
          end
        end

        describe 'pages-custom-domain service' do
          it 'is enabled and exposes correct port' do
            expect(pages_enabled_template.dig('Service/test-gitlab-pages-custom-domains', 'spec', 'ports')).to eq(
              [
                {
                  'port' => 80,
                  'targetPort' => 8090,
                  'protocol' => 'TCP',
                  'name' => 'http-gitlab-pages'
                }
              ]
            )
          end
        end

        describe 'pages TLS secret' do
          it 'is not mounted on Pages pod' do
            pages_secret_mounts = pages_enabled_template.projected_volume_sources(
              'Deployment/test-gitlab-pages',
              'init-pages-secrets'
            )

            tls_mount = pages_secret_mounts.find { |mount| mount['secret']['name'] == 'test-pages-tls' }

            expect(tls_mount).to be_nil
          end
        end
      end

      context 'when only HTTPS custom domains are enabled' do
        let(:pages_enabled_values) do
          YAML.safe_load(%(
            global:
              pages:
                enabled: true
                externalHttps: ['1.2.3.4']
          ))
        end

        describe 'gitlab.yml file' do
          it 'sets externalHTTP to true and externalHTTPS to false' do
            expect(gitlab_yml_data['production']['pages']['external_http']).to be false
            expect(gitlab_yml_data['production']['pages']['external_https']).to be true
          end
        end

        describe 'pages configuration' do
          it 'exposes listen-https, root-cert, and root-key' do
            expect(pages_config_data).to match(/listen-https=0.0.0.0:8091/)
            expect(pages_config_data).to match(%r{root-cert=/etc/gitlab-secrets/pages/pages.example.com.crt})
            expect(pages_config_data).to match(%r{root-key=/etc/gitlab-secrets/pages/pages.example.com.key})
          end

          it 'configures readiness probe correctly' do
            expect(pages_config_data).to match(/listen-http=0.0.0.0:9090/)
            expect(pages_config_data).to match(%r{pages-status=/-/readiness})
          end

          it 'does not expose listen-proxy ' do
            expect(pages_config_data).not_to match(/listen-proxy=/)
          end
        end

        describe 'pages-custom-domain service' do
          it 'is enabled and exposes correct port' do
            expect(pages_enabled_template.dig('Service/test-gitlab-pages-custom-domains', 'spec', 'ports')).to eq(
              [
                {
                  'port' => 443,
                  'targetPort' => 8091,
                  'protocol' => 'TCP',
                  'name' => 'https-gitlab-pages'
                }
              ]
            )
          end
        end

        describe 'pages TLS secret' do
          it 'is mounted on Pages pod' do
            pages_secret_mounts = pages_enabled_template.projected_volume_sources(
              'Deployment/test-gitlab-pages',
              'init-pages-secrets'
            )

            tls_mount = pages_secret_mounts.find { |mount| mount['secret']['name'] == 'test-pages-tls' }

            expect(tls_mount).not_to be_nil
          end
        end
      end

      context 'when both HTTP and HTTPS custom domains are enabled' do
        let(:pages_enabled_values) do
          YAML.safe_load(%(
            global:
              pages:
                enabled: true
                externalHttp: ['1.2.3.4']
                externalHttps: ['1.2.3.4']
          ))
        end

        describe 'gitlab.yml file' do
          it 'sets both externalHTTP and externalHTTPS to true' do
            expect(gitlab_yml_data['production']['pages']['external_http']).to be true
            expect(gitlab_yml_data['production']['pages']['external_https']).to be true
          end
        end

        describe 'pages configuration' do
          it 'exposes listen-http, listen-https, root-cert, and root-key' do
            expect(pages_config_data).to match(/listen-http=0.0.0.0:8090/)
            expect(pages_config_data).to match(/listen-https=0.0.0.0:8091/)
            expect(pages_config_data).to match(%r{root-cert=/etc/gitlab-secrets/pages/pages.example.com.crt})
            expect(pages_config_data).to match(%r{root-key=/etc/gitlab-secrets/pages/pages.example.com.key})
          end

          it 'does not expose listen-proxy ' do
            expect(pages_config_data).not_to match(/listen-proxy=/)
          end
        end

        describe 'pages-custom-domain service' do
          it 'is enabled and exposes correct ports' do
            expect(pages_enabled_template.dig('Service/test-gitlab-pages-custom-domains', 'spec', 'ports')).to eq(
              [
                {
                  'port' => 80,
                  'targetPort' => 8090,
                  'protocol' => 'TCP',
                  'name' => 'http-gitlab-pages'
                },
                {
                  'port' => 443,
                  'targetPort' => 8091,
                  'protocol' => 'TCP',
                  'name' => 'https-gitlab-pages'
                }
              ]
            )
          end
        end

        describe 'pages TLS secret' do
          it 'is mounted on Pages pod' do
            pages_secret_mounts = pages_enabled_template.projected_volume_sources(
              'Deployment/test-gitlab-pages',
              'init-pages-secrets'
            )

            tls_mount = pages_secret_mounts.find { |mount| mount['secret']['name'] == 'test-pages-tls' }

            expect(tls_mount).not_to be_nil
          end
        end
      end

      describe 'custom domains service type' do
        context 'when using LoadBalancer' do
          context 'when only one unique IP address exists combined for both http and https' do
            let(:pages_enabled_values) do
              YAML.safe_load(%(
                global:
                  pages:
                    enabled: true
                    externalHttp: ['1.2.3.4']
                    externalHttps: ['1.2.3.4']
              ))
            end

            it 'sets loadBalancerIP' do
              expect(pages_enabled_template.dig('Service/test-gitlab-pages-custom-domains', 'spec', 'loadBalancerIP')).to eq('1.2.3.4')
            end
          end

          context 'when more than one unique IP address exists combined for both http and https' do
            let(:pages_enabled_values) do
              YAML.safe_load(%(
                global:
                  pages:
                    enabled: true
                    externalHttp: ['1.2.3.4', '1.2.3.5']
                    externalHttps: ['1.2.3.4', '1.2.3.6']
              ))
            end

            it 'sets externalIPs' do
              expect(pages_enabled_template.dig('Service/test-gitlab-pages-custom-domains', 'spec', 'loadBalancerIP')).to be_nil
              expect(pages_enabled_template.dig('Service/test-gitlab-pages-custom-domains', 'spec', 'externalIPs')).to eq(%w[1.2.3.4 1.2.3.5 1.2.3.6])
            end
          end
        end

        context 'when using NodePort' do
          let(:pages_enabled_values) do
            YAML.safe_load(%(
              global:
                pages:
                  enabled: true
                  externalHttp: ['1.2.3.4']
                  externalHttps: ['1.2.3.4']
              gitlab:
                gitlab-pages:
                  service:
                    customDomains:
                      type: NodePort
                      nodePort:
                        http: 30010
                        https: 30011
            ))
          end

          it 'sets NodePort as service type' do
            expect(pages_enabled_template.dig('Service/test-gitlab-pages-custom-domains', 'spec', 'type')).to eq('NodePort')
          end

          it 'exposes node ports' do
            expect(pages_enabled_template.dig('Service/test-gitlab-pages-custom-domains', 'spec', 'ports')).to eq(
              [
                {
                  'port' => 80,
                  'targetPort' => 8090,
                  'protocol' => 'TCP',
                  'name' => 'http-gitlab-pages',
                  'nodePort' => 30010
                },
                {
                  'port' => 443,
                  'targetPort' => 8091,
                  'protocol' => 'TCP',
                  'name' => 'https-gitlab-pages',
                  'nodePort' => 30011
                }
              ]
            )
          end
        end
      end

      context 'when using HTTPS Proxy V2' do
        let(:pages_enabled_values) do
          YAML.safe_load(%(
            global:
              pages:
                enabled: true
                externalHttps:
                  - 1.1.1.1
            gitlab:
              gitlab-pages:
                useProxyV2: true
          ))
        end

        describe 'pages configuration' do
          it 'exposes proper listeners' do
            expect(pages_config_data).to match(/listen-https-proxyv2=0.0.0.0:8091/)
            expect(pages_config_data).not_to match(/listen-https=0.0.0.0:8091/)
          end
        end
      end

      context 'when using HTTP Proxy' do
        let(:pages_enabled_values) do
          YAML.safe_load(%(
            global:
              pages:
                enabled: true
                externalHttp:
                  - 1.1.1.1
                externalHttps:
                  - 1.1.1.1
            gitlab:
              gitlab-pages:
                useHTTPProxy: true
          ))
        end

        describe 'pages configuration' do
          it 'exposes proper listeners' do
            expect(pages_config_data).to match(/listen-proxy=0.0.0.0:8090/)
            expect(pages_config_data).not_to match(/listen-http=0.0.0.0:8090/)
          end
        end
      end
    end
  end
end
