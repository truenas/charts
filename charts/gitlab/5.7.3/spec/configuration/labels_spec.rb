require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Labels configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
      global:
        pod:
          labels:
            environment: development
    ))
  end

  let(:ignored_charts) do
    [
      'Deployment/test-certmanager-cainjector',
      'Deployment/test-certmanager-webhook',
      'Deployment/test-certmanager',
      'Deployment/test-gitlab-runner',
      'Deployment/test-prometheus-server',
      'Deployment/test-minio',
      'Deployment/test-nginx-ingress-controller',
      'Deployment/test-nginx-ingress-default-backend',
      # not included, StatefulSet: postgresql, redis, gitlab/gitaly
    ]
  end

  let(:target_chart) do
    'Deployment/test-webservice-default'
  end

  let(:chart_values) do
    YAML.safe_load(%(
      gitlab:
        webservice:
          podLabels:
            spec/test: local
            environment: local
    ))
  end

  context 'When setting global pod labels' do
    it 'Populates labels for all Pod templates' do
      t = HelmTemplate.new(default_values)
      expect(t.exit_code).to eq(0)

      resources_by_kind = t.resources_by_kind('Deployment').reject{ |key, _| ignored_charts.include? key }

      resources_by_kind.each do |key, _|
        expect(t.dig(key, 'spec', 'template', 'metadata', 'labels')).to include(default_values['global']['pod']['labels'])
      end
    end

    context 'When populating a chart local labels' do
      let(:local_template) do
        HelmTemplate.new(default_values.deep_merge(chart_values))
      end

      it 'Override global' do
        expect(local_template.exit_code).to eq(0)

        resources_by_kind = local_template.resources_by_kind('Deployment').reject{ |key, _| ignored_charts.include? key }
        resources_by_kind.reject!{ |key, _| target_chart.eql? key }

        resources_by_kind.each do |key, _|
          expect(local_template.dig(key, 'spec', 'template', 'metadata', 'labels')).to include(default_values['global']['pod']['labels'])
        end

        expect(local_template.dig(target_chart, 'spec', 'template', 'metadata', 'labels')).to include(chart_values['gitlab']['webservice']['podLabels'])
      end

      it 'Are only present on configured chart' do
        resources_by_kind = local_template.resources_by_kind('Deployment').reject{ |key, _| ignored_charts.include? key }
        resources_by_kind.reject!{ |key, _| target_chart.eql? key }

        resources_by_kind.each do |key, _|
          expect(local_template.dig(key, 'spec', 'template', 'metadata', 'labels')).not_to include(chart_values['gitlab']['webservice']['podLabels'])
        end
      end
    end
  end

  context 'When only local labels present' do
    let(:local_template) do
      HelmTemplate.new(chart_values.deep_merge({'certmanager-issuer' => { 'email' => 'test@example.com' }}))
    end

    it 'Are only present on configured chart' do
      expect(local_template.exit_code).to eq(0)

      resources_by_kind = local_template.resources_by_kind('Deployment').reject{ |key, _| ignored_charts.include? key }
      resources_by_kind.reject!{ |key, _| target_chart.eql? key }

      resources_by_kind.each do |key, _|
        expect(local_template.dig(key, 'spec', 'template', 'metadata', 'labels')).not_to include(chart_values['gitlab']['webservice']['podLabels'])
      end

      expect(local_template.dig(target_chart, 'spec', 'template', 'metadata', 'labels')).to include(chart_values['gitlab']['webservice']['podLabels'])
    end
  end
end
