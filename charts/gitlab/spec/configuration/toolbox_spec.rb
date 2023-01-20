require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'toolbox configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
      gitlab:
        toolbox:
          backups:
            cron:
              enabled: true
              persistence:
                enabled: true
          enabled: true
          persistence:
            enabled: true
          serviceAccount:
            enabled: true
            create: true
    ))
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
          toolbox:
            common:
              labels:
                global: toolbox
                toolbox: toolbox
            networkpolicy:
              enabled: true
            podLabels:
              pod: true
              global: pod
      )).deep_merge(default_values)
    end
    it 'Populates the additional labels in the expected manner' do
      t = HelmTemplate.new(values)
      expect(t.exit_code).to eq(0), "Unexpected error code #{t.exit_code} -- #{t.stderr}"
      expect(t.dig('ConfigMap/test-toolbox', 'metadata', 'labels')).to include('global' => 'toolbox')
      expect(t.dig('CronJob/test-toolbox-backup', 'metadata', 'labels')).to include('global' => 'toolbox')
      expect(t.dig('CronJob/test-toolbox-backup', 'spec', 'jobTemplate', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'toolbox')
      expect(t.dig('Deployment/test-toolbox', 'metadata', 'labels')).to include('foo' => 'global')
      expect(t.dig('Deployment/test-toolbox', 'metadata', 'labels')).to include('global' => 'toolbox')
      expect(t.dig('Deployment/test-toolbox', 'metadata', 'labels')).not_to include('global' => 'global')
      expect(t.dig('Deployment/test-toolbox', 'spec', 'template', 'metadata', 'labels')).to include('global' => 'pod')
      expect(t.dig('Deployment/test-toolbox', 'spec', 'template', 'metadata', 'labels')).to include('pod' => 'true')
      expect(t.dig('Deployment/test-toolbox', 'spec', 'template', 'metadata', 'labels')).to include('global_pod' => 'true')
      expect(t.dig('PersistentVolumeClaim/test-toolbox-tmp', 'metadata', 'labels')).to include('global' => 'toolbox')
      expect(t.dig('PersistentVolumeClaim/test-toolbox-backup-tmp', 'metadata', 'labels')).to include('global' => 'toolbox')
      expect(t.dig('ServiceAccount/test-toolbox', 'metadata', 'labels')).to include('global' => 'toolbox')
    end
  end
end
