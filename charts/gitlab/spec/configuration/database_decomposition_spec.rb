require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Database configuration' do
  def database_yml(template, chart_name)
    template.dig("ConfigMap/test-#{chart_name}", 'data', 'database.yml.erb')
  end

  def database_config(template, chart_name)
    db_config = database_yml(template, chart_name)
    YAML.safe_load(db_config)
  end

  let(:default_values) do
    HelmTemplate.certmanager_issuer.deep_merge(YAML.safe_load(%(
      global:
        psql:
          host: ''
          serviceName: ''
          username: ''
          database: ''
          applicationName: nil
          preparedStatements: ''
          password:
            secret: ''
            key: ''
          connectTimeout: nil
          keepalives: nil
          keepalivesIdle: nil
          keepalivesInterval: nil
          keepalivesCount: nil
          tcpUserTimeout: nil
      postgresql:
        install: true
    )))
  end

  describe 'No decomposition' do
    context 'With default configuration' do
      it '`database.yml` Provides only `main` stanza and uses in-chart postgresql service' do
        t = HelmTemplate.new(default_values)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        db_config = database_config(t, 'webservice')
        expect(db_config['production'].keys).to contain_exactly('main')
        expect(db_config['production'].dig('main', 'host')).to eq('test-postgresql.default.svc')
      end
    end

    context 'When `main` is provided' do
      it 'inherits settings from x.psql where not provided, uses own' do
        t = HelmTemplate.new(default_values.deep_merge(YAML.safe_load(%(
          global:
            psql:
              password:
                secret: sekrit
                key: pa55word
              main:
                host: server
                port: 9999
        ))))

        db_config = database_config(t, 'webservice')
        expect(db_config['production'].dig('main', 'host')).to eq('server')
        expect(db_config['production'].dig('main', 'port')).to eq(9999)

        webservice_secret_mounts = t.projected_volume_sources('Deployment/test-webservice-default', 'init-webservice-secrets').select do |item|
          item['secret']['name'] == 'sekrit' && item['secret']['items'][0]['key'] == 'pa55word'
        end
        expect(webservice_secret_mounts.length).to eq(1)
      end
    end
  end

  describe 'Invalid decomposition (x.psql.bogus)' do
    let(:decompose_bogus) do
      default_values.deep_merge(YAML.safe_load(%(
        global:
          psql:
            bogus:
              host: bogus
      )))
    end

    context 'database.yml' do
      it 'Does not contain `bogus` stanza' do
        t = HelmTemplate.new(decompose_bogus)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        db_config = database_config(t, 'webservice')
        expect(db_config['production'].keys).not_to include('bogus')
      end
    end

    context 'volumes' do
      it 'Does not template password files for `bogus` stanza' do
        t = HelmTemplate.new(decompose_bogus)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        webservice_secret_mounts = t.projected_volume_sources('Deployment/test-webservice-default', 'init-webservice-secrets').select do |item|
          item['secret']['items'][0]['key'] == 'postgresql-password' && item['secret']['items'][0]['path'] == 'postgres/psql-password-bogus'
        end
        expect(webservice_secret_mounts.length).to eq(0)
      end
    end
  end

  describe 'Stanzas inherit from `main` when present, `psql` when not in `main`' do
    let(:decompose_inherit) do
      default_values.deep_merge(YAML.safe_load(%(
        global:
          psql:
            username: global-user
            applicationName: global-application
            main:
              host: main-server
              port: 9999
            ci:
              username: ci-user
      )))
    end

    let(:sidekiq_override) do
      decompose_inherit.deep_merge(YAML.safe_load(%(
        gitlab:
          sidekiq:
            psql:
              main:
                load_balancing:
                  hosts:
                    - a.sidekiq.global
                    - b.sidekiq.global
        postgresql: # must disable for load_balancing
          install: false
      )))
    end

    context 'database.yml' do
      it 'Settings inherited per expectation: host from main, user from global' do
        t = HelmTemplate.new(decompose_inherit)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        db_config = database_config(t, 'webservice')
        expect(db_config['production'].keys).to contain_exactly('main', 'ci')

        # check `main` stanza
        main_config = db_config['production']['main']
        expect(main_config['host']).to eq('main-server')
        expect(main_config['port']).to eq(9999)
        expect(main_config['username']).to eq('global-user')
        expect(main_config['application_name']).to eq('global-application')

        # check `ci` stanza
        ci_config = db_config['production']['ci']
        expect(ci_config['host']).to eq('main-server')
        expect(ci_config['port']).to eq(9999)
        expect(ci_config['username']).to eq('ci-user')
        expect(ci_config['application_name']).to eq('global-application')
      end
    end

    describe 'Sidekiq overrides psql.main.load_balancing' do
      it 'Uses local settings for load_balancing' do
        t = HelmTemplate.new(sidekiq_override)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        sidekiq_config = database_config(t, 'sidekiq')
        sidekiq_config = sidekiq_config['production']['main']
        expect(sidekiq_config).to include('load_balancing')

        webservice_config = database_config(t, 'webservice')
        webservice_config = webservice_config['production']['main']
        expect(webservice_config).not_to include('load_balancing')
      end
    end
  end

  describe 'CI is decomposed (x.psql.ci)' do
    let(:decompose_ci) do
      default_values.deep_merge(YAML.safe_load(%(
        global:
          psql:
            ci:
              foo: bar
      )))
    end

    context 'With minimal configuration' do
      it 'Provides `main` and `ci` stanzas' do
        t = HelmTemplate.new(decompose_ci)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        db_config = database_config(t, 'webservice')
        expect(db_config['production'].keys).to contain_exactly('main', 'ci')
        expect(db_config['production'].dig('main', 'host')).to eq('test-postgresql.default.svc')
        expect(db_config['production'].dig('ci', 'host')).to eq('test-postgresql.default.svc')
      end

      it 'Places `main` stanza first' do
        t = HelmTemplate.new(decompose_ci)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        database_yml = database_yml(t, 'webservice')
        expect(database_yml).to match("production:\n  main:\n")
      end

      it 'Templates different password files for each stanza' do
        t = HelmTemplate.new(decompose_ci)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
        database_yml = database_yml(t, 'webservice')
        expect(database_yml).to include('/etc/gitlab/postgres/psql-password-main', '/etc/gitlab/postgres/psql-password-ci')
      end
    end

    context 'With complex configuration' do
      # This test shows using different user/password/application, inheriting load_balancing.
      let(:complex_ci) do
        decompose_ci.deep_merge(YAML.safe_load(%(
          global:
            psql:
              host: global-server
              password:
                secret: global-psql
              load_balancing:
                hosts:
                - a.secondary.global
                - b.secondary.global
              main:
                username: main-user
                password:
                  secret: main-password
                applicationName: main
              ci:
                username: ci-user
                password:
                  secret: ci-password
                applicationName: ci
          postgresql:
            install: false
        )))
      end

      it 'Templates each group according to overrides' do
        t = HelmTemplate.new(complex_ci)
        expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"

        db_config = database_config(t, 'webservice')
        expect(db_config['production'].keys).to contain_exactly('main', 'ci')

        # check `main` stanza
        main_config = db_config['production']['main']
        expect(main_config['host']).to eq('global-server')
        expect(main_config['port']).to eq(5432)
        expect(main_config['username']).to eq('main-user')
        expect(main_config['application_name']).to eq('main')
        expect(main_config['load_balancing']).to eq({ 'hosts' => ['a.secondary.global', 'b.secondary.global'] })

        # check `ci` stanza
        ci_config = db_config['production']['ci']
        expect(ci_config['host']).to eq('global-server')
        expect(ci_config['port']).to eq(5432)
        expect(ci_config['username']).to eq('ci-user')
        expect(ci_config['application_name']).to eq('ci')
        expect(ci_config['load_balancing']).to eq({ 'hosts' => ['a.secondary.global', 'b.secondary.global'] })

        # Check the secret mounts
        webservice_secret_mounts = t.projected_volume_sources('Deployment/test-webservice-default', 'init-webservice-secrets').select do |item|
          item['secret']['items'][0]['key'] == 'postgresql-password'
        end
        psql_secret_mounts = webservice_secret_mounts.map { |x| x['secret']['name'] }
        expect(psql_secret_mounts).to contain_exactly('main-password', 'ci-password')
      end
    end
  end
end
