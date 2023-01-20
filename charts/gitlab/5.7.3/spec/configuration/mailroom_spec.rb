require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Mailroom configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
      global:
        appConfig:
          incomingEmail:
            enabled: true
            password:
              secret: mailroom-password
    ))
  end

  context 'When using all defaults' do
    it 'Populate internal Redis service' do
      t = HelmTemplate.new(default_values)
      expect(t.exit_code).to eq(0)
      # check the default service name & password are used
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include("test-redis-master.default.svc:6379")
      # check the default secret is mounted
      projected_volume = t.projected_volume_sources('Deployment/test-mailroom','init-mailroom-secrets')
      redis_mount =  projected_volume.select { |item| item['secret']['name'] == "test-redis-secret" }
      expect(redis_mount.length).to eq(1)
      # check there are no Sentinels
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).not_to include(":sentinels:")
    end
  end

  context 'with IMAP settings' do
    let(:incoming_email_settings) do
      YAML.safe_load(%(
        incomingEmail:
          enabled: true
          address: incoming+%{key}@test.example.com
          host: example.com
          port: 993
          ssl: true
          startTls: true
          user: myusername
          password:
            secret: mailroom-secret
      ))
    end

    let(:app_config) { incoming_email_settings }

    let(:values) do
      YAML.safe_load(%(
        certmanager-issuer:
          email: test@example.com
        global:
          appConfig: #{app_config.to_json}
      ))
    end

    let(:template) { HelmTemplate.new(values) }

    let(:raw_mail_room_yml) { template.dig('ConfigMap/test-mailroom', 'data', 'mail_room.yml') }

    let(:mail_room_yml) do
      data = raw_mail_room_yml.dup
      data.gsub!(/:password: .*/, ':password: secret')
      data.gsub!(/:redis_url: .*/, 'redis_url: redis://test.example.com')
      YAML.safe_load(data, permitted_classes: [Symbol])
    end

    let(:mailbox) { mail_room_yml[:mailboxes].first }

    it 'renders mail_room.yml' do
      t = HelmTemplate.new(values)

      expect(t.exit_code).to eq(0)
      expect(mail_room_yml[:mailboxes].length).to eq(1)
      expect(raw_mail_room_yml).to include(%(:password: <%= File.read("/etc/gitlab/mailroom/password_incoming_email").strip.to_json %>))
      expect(mailbox[:email]).to eq('myusername')
      expect(mailbox[:name]).to eq('inbox')
      expect(mailbox[:delete_after_delivery]).to be true
      expect(mailbox[:inbox_method]).to eq('imap')
      expect(mailbox[:host]).to eq('example.com')
      expect(mailbox[:port]).to eq(993)
      expect(mailbox[:ssl]).to be true
      expect(mailbox[:start_tls]).to be true
      expect(mailbox[:inbox_options]).to be_nil
    end

    context 'with Service Desk' do
      let(:app_config) do
        incoming_email_settings.merge(YAML.safe_load(%(
          serviceDeskEmail:
            enabled: true
            address: incoming+%{key}@test.example2.com
            host: example2.com
            port: 587
            ssl: false
            startTls: false
            user: servicedesk
            password:
              secret: mailroom-secret
        )))
      end

      let(:mailbox) { mail_room_yml[:mailboxes].last }

      it 'renders both mailboxes in mail_room.yml' do
        t = HelmTemplate.new(values)

        expect(t.exit_code).to eq(0)
        expect(mail_room_yml[:mailboxes].length).to eq(2)
        expect(raw_mail_room_yml).to include(%(:password: <%= File.read("/etc/gitlab/mailroom/password_service_desk").strip.to_json %>))
        expect(mailbox[:email]).to eq('servicedesk')
        expect(mailbox[:name]).to eq('inbox')
        expect(mailbox[:delete_after_delivery]).to be true
        expect(mailbox[:inbox_method]).to eq('imap')
        expect(mailbox[:host]).to eq('example2.com')
        expect(mailbox[:port]).to eq(587)
        expect(mailbox[:ssl]).to be false
        expect(mailbox[:start_tls]).to be false
        expect(mailbox[:inbox_options]).to be_nil
      end
    end
  end

  context 'with Microsoft Graph settings' do
    let(:incoming_email_settings) do
      YAML.safe_load(%(
        incomingEmail:
          enabled: true
          address: incoming+%{key}@test.example.com
          inboxMethod: microsoft_graph
          tenantId: SOME-TENANT-ID
          clientId: SOME-CLIENT-ID
          clientSecret:
            secret: mailroom-client-id
          pollInterval: 30
      ))
    end

    let(:app_config) { incoming_email_settings }

    let(:values) do
      YAML.safe_load(%(
        certmanager-issuer:
          email: test@example.com
        global:
          appConfig: #{app_config.to_json}
      ))
    end

    let(:template) { HelmTemplate.new(values) }

    let(:raw_mail_room_yml) { template.dig('ConfigMap/test-mailroom', 'data', 'mail_room.yml') }

    let(:mail_room_yml) do
      data = raw_mail_room_yml.dup
      data.gsub!(/:client_secret: .*/, ':client_secret: secret')
      data.gsub!(/:redis_url: .*/, 'redis_url: redis://test.example.com')
      YAML.safe_load(data, permitted_classes: [Symbol])
    end

    let(:mailbox) { mail_room_yml[:mailboxes].first }

    it 'renders mail_room.yml' do
      t = HelmTemplate.new(values)

      expect(t.exit_code).to eq(0)
      expect(mail_room_yml[:mailboxes].length).to eq(1)
      expect(raw_mail_room_yml).to include(%(:client_secret: <%= File.read("/etc/gitlab/mailroom/client_id_incoming_email").strip.to_json %>))
      expect(mailbox[:inbox_options]).to be_a(Hash)
      expect(mailbox[:inbox_options][:tenant_id]).to eq('SOME-TENANT-ID')
      expect(mailbox[:inbox_options][:client_id]).to eq('SOME-CLIENT-ID')
      expect(mailbox[:inbox_options][:client_secret]).to eq('secret')
      expect(mailbox[:inbox_options][:poll_interval]).to eq(30)
    end

    context 'with Service Desk' do
      let(:app_config) do
        incoming_email_settings.merge(YAML.safe_load(%(
          serviceDeskEmail:
            enabled: true
            address: servicedesk+%{key}@test.example.com
            inboxMethod: microsoft_graph
            tenantId: OTHER-TENANT-ID
            clientId: OTHER-CLIENT-ID
            clientSecret:
              secret: mailroom-client-id
            pollInterval: 45
        )))
      end
      let(:mailbox) { mail_room_yml[:mailboxes].last }

      it 'renders both mailboxes in mail_room.yml' do
        t = HelmTemplate.new(values)

        expect(t.exit_code).to eq(0)
        expect(mail_room_yml[:mailboxes].length).to eq(2)
        expect(raw_mail_room_yml).to include(%(:client_secret: <%= File.read("/etc/gitlab/mailroom/client_id_service_desk").strip.to_json %>))
        expect(mailbox[:inbox_options]).to be_a(Hash)
        expect(mailbox[:inbox_options][:tenant_id]).to eq('OTHER-TENANT-ID')
        expect(mailbox[:inbox_options][:client_id]).to eq('OTHER-CLIENT-ID')
        expect(mailbox[:inbox_options][:client_secret]).to eq('secret')
        expect(mailbox[:inbox_options][:poll_interval]).to eq(45)
      end
    end
  end

  context 'When global.redis is present' do
    let(:values) do
      YAML.safe_load(%(
        global:
          redis:
            host: external-redis
            port: 9999
            password:
              enable: true
              secret: external-redis-secret
              key: external-redis-key
      )).deep_merge(default_values)
    end

    it 'Populates configured external host, port, password' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0)
      # configure the external-redis server, port, secret
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include("external-redis:9999")
      projected_volume = t.projected_volume_sources('Deployment/test-mailroom','init-mailroom-secrets')
      redis_mount =  projected_volume.select { |item| item['secret']['name'] == "external-redis-secret" }
      expect(redis_mount.length).to eq(1)
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).not_to include(":sentinels:")
    end

    it 'Populates Sentinels, when configured' do
      local = YAML.safe_load(%(
        global:
          redis:
            sentinels:
            - host: s1.resque.redis
              port: 26379
            - host: s2.resque.redis
              port: 26379
      ))
      t = HelmTemplate.new(values.deep_merge(local))
      expect(t.exit_code).to eq(0)
      # check that global.sentinels populate
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include(":sentinels:")
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include("s1.resque.redis")
    end
  end

  context 'When global.redis.queues is present' do
    let(:values) do
      YAML.safe_load(%(
        global:
          redis:
            host: resque.redis
            sentinels:
            - host: s1.resque.redis
              port: 26379
            - host: s2.resque.redis
              port: 26379
            queues:
              host: queue.redis
              password:
                secret: redis-queues-secret
                key: redis-queues-key
        redis:
          install: false
      )).deep_merge(default_values)
    end

    it 'populates the Queues host, port, password (without Sentinels)' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0)
      # check the `queue.redis` is populated instead of `resque.redis`
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).not_to include("resque.redis")
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include("queue.redis")
      # check mount of the secret
      projected_volume = t.projected_volume_sources('Deployment/test-mailroom','init-mailroom-secrets')
      redis_mount =  projected_volume.select { |item| item['secret']['name'] == "redis-queues-secret" }
      expect(redis_mount.length).to eq(1)
      # no Sentinels present
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).not_to include(":sentinels:")
    end

    it 'separate sentinels are populated, when present' do
      local = YAML.safe_load(%(
        global:
          redis:
            queues:
              sentinels:
              - host: s1.queue.redis
                port: 26379
              - host: s2.queue.redis
                port: 26379
      ))
      t = HelmTemplate.new(values.deep_merge(local))
      expect(t.exit_code).to eq(0)
      # check that queues.sentinels are used instead of global.sentinels
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include(":sentinels:")
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).to include("s1.queue.redis")
      expect(t.dig('ConfigMap/test-mailroom','data','mail_room.yml')).not_to include("s1.resque.redis")
    end
  end

  context 'When customer provides additional labels' do
    let(:values) do
      YAML.safe_load(%(
        global:
          common:
            labels:
              global: global
              foo: global
          pod:
            labels:
              global_pod: true
        gitlab:
          mailroom:
            common:
              labels:
                global: mailroom
                mailroom: mailroom
            networkpolicy:
              enabled: true
            podLabels:
              pod: true
              global: pod
            serviceAccount:
              create: true
              enabled: true
      )).deep_merge(default_values)
    end
    it 'Populates the additional labels in the expected manner' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(t.dig('ConfigMap/test-mailroom', 'metadata', 'labels')).to include('global' => 'mailroom')
      expect(t.dig('Deployment/test-mailroom', 'metadata', 'labels')).to include('foo' => 'global')
      expect(t.dig('Deployment/test-mailroom', 'metadata', 'labels')).to include('global' => 'mailroom')
      expect(t.dig('Deployment/test-mailroom', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('Deployment/test-mailroom', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
      expect(t.dig('Deployment/test-mailroom', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
      expect(t.dig('Deployment/test-mailroom', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
      expect(t.dig('HorizontalPodAutoscaler/test-mailroom', 'metadata', 'labels')).to include('global' => 'mailroom')
      expect(t.dig('NetworkPolicy/test-mailroom-v1', 'metadata', 'labels')).to include('global' => 'mailroom')
      expect(t.dig('ServiceAccount/test-mailroom', 'metadata', 'labels')).to include('global' => 'mailroom')
    end
  end

  context 'with incoming_email webhook delivery method' do
    let(:auth_token_secret) { "test-mailroom-auth-token" }

    let(:incoming_email_settings) do
      YAML.safe_load(%(
        incomingEmail:
          enabled: true
          password:
            secret: mailroom-secret
          deliveryMethod: webhook
          authToken:
            secret: "#{auth_token_secret}"
      ))
    end

    let(:app_config) { incoming_email_settings }

    let(:values) do
      YAML.safe_load(%(
        certmanager-issuer:
          email: test@example.com
        global:
          appConfig: #{app_config.to_json}
      ))
    end

    let(:template) { HelmTemplate.new(values) }

    let(:mail_room_yml) do
      YAML.safe_load(template.dig('ConfigMap/test-mailroom', 'data', 'mail_room.yml'), permitted_classes: [Symbol])
    end

    let(:gitlab_yml) do
      YAML.safe_load(template.dig("ConfigMap/test-webservice", "data", "gitlab.yml.erb"), permitted_classes: [Symbol])
    end

    it 'renders mail_room.yml' do
      expect(template.exit_code).to eq(0)
      expect(mail_room_yml[:mailboxes].length).to eq(1)

      mail_box = mail_room_yml[:mailboxes].first

      expect(mail_box[:delivery_method]).to eq('postback')
      expect(mail_box[:delivery_options]).to eq(
        delivery_url: 'http://test-webservice-default.default.svc:8181/api/v4/internal/mail_room/incoming_email',
        jwt_auth_header: "Gitlab-Mailroom-Api-Request",
        jwt_issuer: "gitlab-mailroom",
        jwt_algorithm: "HS256",
        jwt_secret_path: "/etc/gitlab/mailroom/incoming_email_webhook_secret"
      )

      projected_secret = template.get_projected_secret('Deployment/test-mailroom', 'init-mailroom-secrets', 'test-mailroom-auth-token')
      expect(projected_secret).to eql(
        "name" => "test-mailroom-auth-token",
        "items" => [
          {
            "key" => "authToken",
            "path" => "mailroom/incoming_email_webhook_secret"
          }
        ]
      )
    end

    it 'adds secret_file support to incoming_email config inside gitlab.yml of webservice' do
      expect(gitlab_yml["production"]["incoming_email"]).to include(
        "secret_file" => "/etc/gitlab/mailroom/incoming_email_webhook_secret"
      )
      projected_secret = template.get_projected_secret('Deployment/test-webservice-default', 'init-webservice-secrets', 'test-mailroom-auth-token')
      expect(projected_secret).to eql(
        "name" => "test-mailroom-auth-token",
        "items" => [
          {
            "key" => "authToken",
            "path" => "mailroom/incoming_email_webhook_secret"
          }
        ]
      )
    end

    context 'when authToken.secret is empty' do
      let(:auth_token_secret) { "" }
      let(:default_secret_name) { 'test-incoming-email-auth-token' }

      it 'uses a default secret name' do
        expect(template.get_projected_secret('Deployment/test-mailroom', 'init-mailroom-secrets', default_secret_name)).not_to be_empty
        expect(template.get_projected_secret('Deployment/test-webservice-default', 'init-webservice-secrets', default_secret_name)).not_to be_empty
      end
    end
  end

  context 'with service_desk_email webhook delivery method' do
    let(:auth_token_secret) { "test-mailroom-auth-token" }

    let(:app_config) do
      YAML.safe_load(%(
        incomingEmail:
          enabled: true
          address: incoming+%{key}@test.example2.com
          password:
            secret: mailroom-secret
        serviceDeskEmail:
          enabled: true
          address: incoming+%{key}@test.example2.com
          password:
            secret: mailroom-secret
          deliveryMethod: webhook
          authToken:
            secret: "#{auth_token_secret}"
      ))
    end

    let(:values) do
      YAML.safe_load(%(
        certmanager-issuer:
          email: test@example.com
        global:
          appConfig: #{app_config.to_json}
      ))
    end

    let(:template) { HelmTemplate.new(values) }

    let(:mail_room_yml) do
      YAML.safe_load(template.dig('ConfigMap/test-mailroom', 'data', 'mail_room.yml'), permitted_classes: [Symbol])
    end

    let(:gitlab_yml) do
      YAML.safe_load(template.dig("ConfigMap/test-webservice", "data", "gitlab.yml.erb"), permitted_classes: [Symbol])
    end

    it 'renders mail_room.yml' do
      puts template.stderr
      expect(template.exit_code).to eq(0)
      expect(mail_room_yml[:mailboxes].length).to eq(2)

      mail_box = mail_room_yml[:mailboxes].last
      expect(mail_box[:delivery_method]).to eq('postback')
      expect(mail_box[:delivery_options]).to eq(
        delivery_url: 'http://test-webservice-default.default.svc:8181/api/v4/internal/mail_room/service_desk_email',
        jwt_auth_header: "Gitlab-Mailroom-Api-Request",
        jwt_issuer: "gitlab-mailroom",
        jwt_algorithm: "HS256",
        jwt_secret_path: "/etc/gitlab/mailroom/service_desk_email_webhook_secret"
      )

      projected_secret = template.get_projected_secret('Deployment/test-mailroom', 'init-mailroom-secrets', 'test-mailroom-auth-token')
      expect(projected_secret).to eql(
        "name" => "test-mailroom-auth-token",
        "items" => [
          {
            "key" => "authToken",
            "path" => "mailroom/service_desk_email_webhook_secret"
          }
        ]
      )
    end

    it 'adds secret_file support to service_desk_email config inside gitlab.yml of webservice' do
      expect(gitlab_yml["production"]["service_desk_email"]).to include(
        "secret_file" => "/etc/gitlab/mailroom/service_desk_email_webhook_secret"
      )
      projected_secret = template.get_projected_secret('Deployment/test-webservice-default', 'init-webservice-secrets', 'test-mailroom-auth-token')
      expect(projected_secret).to eql(
        "name" => "test-mailroom-auth-token",
        "items" => [
          {
            "key" => "authToken",
            "path" => "mailroom/service_desk_email_webhook_secret"
          }
        ]
      )
    end

    context 'when authToken.secret is empty' do
      let(:auth_token_secret) { "" }
      let(:default_secret_name) { 'test-service-desk-email-auth-token' }

      it 'uses a default secret name' do
        expect(template.get_projected_secret('Deployment/test-mailroom', 'init-mailroom-secrets', default_secret_name)).not_to be_empty
        expect(template.get_projected_secret('Deployment/test-webservice-default', 'init-webservice-secrets', default_secret_name)).not_to be_empty
      end
    end
  end
end
