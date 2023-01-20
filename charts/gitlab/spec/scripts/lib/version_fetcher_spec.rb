require 'spec_helper'
require_relative '../../../scripts/lib/version_fetcher.rb'

describe VersionFetcher do
  let(:com_path) { 'gitlab-org%2Fgitlab-foss/repository/files/GITLAB_SHELL_VERSION/raw?ref=v11.8.0' }
  let(:dev_path) { 'gitlab%2Fgitlabhq/repository/files/GITLAB_SHELL_VERSION/raw?ref=v11.8.0' }
  let(:custom_path) { 'johndoe%2Fgitlab-ee/repository/files/GITLAB_SHELL_VERSION/raw?ref=v11.8.0' }
  before do
    allow(ENV).to receive(:[]).and_call_original
    allow(ENV).to receive(:[]).with('FETCH_DEV_ARTIFACTS_PAT').and_return(nil)
  end

  describe 'detecting API URL' do
    it 'works correctly gitlab.com registry' do
      version_fetcher = VersionFetcher.new('v11.8.0', 'gitlab-org/gitlab-foss')
      allow(version_fetcher).to receive_message_chain(:open, :read).and_return("1.2.3\n")

      expect(version_fetcher).to receive(:open).with("https://gitlab.com/api/v4/projects/#{com_path}", { 'PRIVATE-TOKEN' => nil })
      version_fetcher.fetch('gitlab-shell')
    end

    it 'works correctly dev registry' do
      allow(ENV).to receive(:[]).with('FETCH_DEV_ARTIFACTS_PAT').and_return('myrandomtoken')
      version_fetcher = VersionFetcher.new('v11.8.0', 'gitlab/gitlabhq')
      allow(version_fetcher).to receive_message_chain(:open, :read).and_return("1.2.3\n")

      expect(version_fetcher).to receive(:open).with("https://dev.gitlab.org/api/v4/projects/#{dev_path}", { 'PRIVATE-TOKEN' => 'myrandomtoken'})
      version_fetcher.fetch('gitlab-shell')
    end

    it 'falls back correctly to current registry for unknown projects' do
      version_fetcher = VersionFetcher.new('v11.8.0', 'johndoe/gitlab-ee')
      allow(version_fetcher).to receive_message_chain(:open, :read).and_return("1.2.3\n")

      expect(version_fetcher).to receive(:open).with("#{ENV['CI_API_V4_URL']}/projects/#{custom_path}", { 'PRIVATE-TOKEN' => nil})
      version_fetcher.fetch('gitlab-shell')
    end
  end

  describe 'instance methods' do
    let(:auto_deploy) { false }
    let(:version_fetcher) { VersionFetcher.new('v11.8.0', 'gitlab-org/gitlab-foss', auto_deploy: auto_deploy) }

    before do
      allow(version_fetcher).to receive_message_chain(:open, :read).and_return("1.2.3\n")
      allow(version_fetcher).to receive(:gitlab_shell).and_call_original
      allow(version_fetcher).to receive(:gitaly).and_call_original
    end

    context 'when using an auto-deploy fetcher' do
      let(:auto_deploy) { true }

      describe '#gitlab_shell' do
        it 'returns correct value' do
          expect(version_fetcher).to receive(:version_from_env).with('GITLAB_SHELL_VERSION').and_return('3.2.1')
          expect(version_fetcher).not_to receive(:open)

          expect(version_fetcher.gitlab_shell).to eq('3.2.1')
        end
      end

      describe '#gitaly' do
        it 'returns correct value' do
          expect(version_fetcher).to receive(:version_from_env).with('GITALY_SERVER_VERSION').and_return('3.2.1')
          expect(version_fetcher).not_to receive(:open)

          expect(version_fetcher.gitaly).to eq('3.2.1')
        end
      end

      describe '#mailroom' do
        it 'returns correct value' do
          expect(version_fetcher).to receive(:version_from_env).with('MAILROOM_VERSION').and_return('3.2.1')
          expect(version_fetcher).not_to receive(:open)

          expect(version_fetcher.mailroom).to eq('3.2.1')
        end
      end
    end

    describe '#gitlab_shell' do
      it 'returns correct value' do
        expect(version_fetcher).not_to receive(:version_from_env)

        expect(version_fetcher.gitlab_shell).to eq('1.2.3')
      end
    end

    describe '#gitaly' do
      it 'returns correct value' do
        expect(version_fetcher).not_to receive(:version_from_env)

        expect(version_fetcher.gitaly).to eq('1.2.3')
      end
    end

    describe '#fetch' do
      it 'calls subchart methods' do
        expect(version_fetcher).to receive(:gitlab_shell)
        expect(version_fetcher).to receive(:gitaly)
        version_fetcher.fetch('gitlab-shell')
        version_fetcher.fetch('gitaly')
      end
    end

    describe '#version_from_env' do
      def version_from_env(key)
        version_fetcher.send(:version_from_env, key)
      end

      it 'reads the value from ENV["AUTO_DEPLOY_COMPONENT_NAME_VERSION]' do
        expect(ENV).to receive(:[])
                         .with('AUTO_DEPLOY_COMPONENT_NAME_VERSION')
                         .and_return('1.2.3')

        expect(version_from_env('NAME_VERSION')).to eq('1.2.3')
      end

      it 'normalizes the version, removing the "v" prefix' do
        expect(ENV).to receive(:[])
                         .with('AUTO_DEPLOY_COMPONENT_NAME_VERSION')
                         .and_return('v1.2.3')

        expect(version_from_env('NAME_VERSION')).to eq('1.2.3')
      end

      it 'raises an error if the version is not defined' do
        expect(ENV).to receive(:[])
                         .with('AUTO_DEPLOY_COMPONENT_NAME_VERSION')
                         .and_return(nil)

        expect do
          version_from_env('NAME_VERSION')
        end.to raise_error("Can't find AUTO_DEPLOY_COMPONENT_NAME_VERSION environment variable")
      end
    end
  end
end
