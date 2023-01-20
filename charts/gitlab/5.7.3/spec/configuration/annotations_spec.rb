# frozen_string_literal: true

require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'Annotations configuration' do
  let(:default_values) do
    HelmTemplate.certmanager_issuer.deep_merge(YAML.safe_load(%(
      global:
        deployment:
          annotations:
            environment: development
      gitlab:
        kas:
          enabled: true  # DELETE THIS WHEN KAS BECOMES ENABLED BY DEFAULT
    )))
  end

  let(:ignored_charts) do
    [
      'Deployment/test-certmanager-cainjector',
      'Deployment/test-certmanager-webhook',
      'Deployment/test-certmanager',
      'Deployment/test-gitlab-runner',
      'Deployment/test-prometheus-server'
    ]
  end

  context 'When setting global deployment annotations' do
    it 'Populates annotations for all deployments' do
      t = HelmTemplate.new(default_values)
      expect(t.exit_code).to eq(0)

      resources_by_kind = t.resources_by_kind('Deployment').reject { |key, _| ignored_charts.include? key }

      resources_by_kind.each do |key, _|
        expect(t.annotations(key)).to include(default_values['global']['deployment']['annotations'])
      end
    end
  end
end
