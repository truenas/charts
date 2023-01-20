require 'spec_helper'
require 'helm_template_helper'

describe 'example configurations' do
  root = File.join(__dir__, '..', '..')

  Dir["#{root}/examples/**/*.{yaml,yml}"].each do |path|
    it "renders #{path.delete_prefix(root).delete_prefix('/')}", :aggregate_failures do
      result = Open3.capture3("#{HelmTemplate.helm_template_call(release_name: 'gitlab-examples-test', path: path)} --set certmanager-issuer.email=me@example.com")

      stdout, stderr, exit_code = result

      expect(exit_code.to_i).to eq(0), "helm template generated error for #{path}"
      expect(stdout).to include('name: gitlab-examples-test')
      expect(stderr).to be_empty
    end
  end
end
