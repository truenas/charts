require 'spec_helper'

load File.expand_path('../../scripts/manage_version.rb', __dir__)

describe 'scripts/manage_version.rb' do
  describe VersionOptionsParser do
    describe '.parse' do
      subject { described_class }

      it 'defaults to disabled auto_deploy' do
        options = subject.parse(%w[--app-version 13.0.0])

        expect(options.auto_deploy).to be_falsey
      end

      context 'when --auto-deploy is provided' do
        def parse_auto_deploy(args)
          subject.parse(args + %w[--auto-deploy])
        end

        it 'works' do
          app_version = '12.9.202002191723+d42c6afcade'
          options = parse_auto_deploy(['--app-version', app_version, '--include-subcharts'])

          expect(options.auto_deploy).to be_truthy
          expect(options.app_version).to eq(app_version)
          expect(options.include_subcharts).to be_truthy
        end

        it 'does not allow --chart-version' do
          extra_params = %w[--chart-version 1.2.3 --app-version 13.0.0]

          expect do
            parse_auto_deploy(extra_params)
          end.to raise_error(RuntimeError, 'Must not specify --chart-version when --auto-deploy is set')
        end

        it 'requires an app-version with build metadata' do
          extra_params = %w[--app-version 13.0.0]

          expect do
            parse_auto_deploy(extra_params)
          end.to raise_error(RuntimeError, 'Must specify a valid --app-version with build metadata eg: 12.9.202002191723+d42c6afcade')
        end
      end
    end
  end

  describe VersionUpdater do
    let(:chart_file) { instance_double("ChartFile") }
    let(:options) { Options.new }
    let(:version_mapping) { instance_double("VersionMapping") }

    before do
      allow_any_instance_of(described_class).to receive(:subcharts).and_return([])
      allow_any_instance_of(described_class).to receive(:chart).and_return(chart_file)
      allow_any_instance_of(described_class).to receive(:working_dir).and_return(nil)
      allow_any_instance_of(described_class).to receive(:version_mapping).and_return(version_mapping)
    end

    describe 'populate_chart_version' do
      context 'chart_version and app_version provided' do
        it 'sets the correct versions' do
          stub_versions(new_version: 'chart-version', new_app_version: 'app-version')

          expect(chart_file).to receive(:update_versions).with('chart-version', 'app-version')
          expect(version_mapping).not_to receive(:insert_version)
          described_class.new(options)
        end
      end

      context 'app_version not provided' do
        it 'sets the correct versions' do
          stub_versions(new_version: 'chart-version')

          expect(chart_file).to receive(:update_versions).with('chart-version', nil)
          expect(version_mapping).not_to receive(:insert_version)
          described_class.new(options)
        end
      end

      context 'when managing an auto-deploy tag' do
        let(:app_version) { '12.0.0-202004171205+d42c6afcade' }

        before do
          stub_versions(auto_deploy: true, new_app_version: app_version)
        end

        it 'defaults chart-version to app-version' do
          expect(chart_file).to receive(:update_versions)
                                  .with(app_version, app_version)

          described_class.new(options)
        end

        it 'does not add version mapping entry' do
          expect(version_mapping).not_to receive(:insert_version)

          described_class.new(options)
        end

        it 'fetches subchart versions in auto-deploy mode' do
          options.include_subcharts = true

          expect(VersionFetcher).to receive(:new)
                                      .with(app_version, anything, auto_deploy: true)
                                      .and_return(double(fetch: 'v1.1.1'))

          described_class.new(options)
        end
      end

      context 'chart_version and app_version provided on master branch' do
        it 'ignores app_version for update_versions, adds version mapping entry' do
          stub_versions(new_version: '1.0.0', app_version: 'master', new_app_version: '1.0.0', branch: 'master')

          expect(chart_file).to receive(:update_versions).with('1.0.0', nil)
          expect(version_mapping).to receive(:insert_version).with('1.0.0', '1.0.0')
          described_class.new(options)
        end
      end

      context 'chart_version not provided' do
        it 'exits if app_version has not changed' do
          stub_versions(app_version: '0.0.1', new_app_version: '0.0.1')

          expect do
            expect { described_class.new(options) }.to output.to_stdout
          end.to raise_error(SystemExit)
        end

        context 'from master branch' do
          it 'increases chart patch when receiving an app patch' do
            stub_versions(version: '0.0.1', app_version: 'master', new_app_version: '10.8.1')

            expect(chart_file).to receive(:update_versions).with('0.0.2', '10.8.1')
            expect(version_mapping).to receive(:insert_version).with('0.0.2', '10.8.1')
            described_class.new(options)
          end

          it 'increases chart minor when receiving an app minor' do
            stub_versions(version: '0.0.1', app_version: 'master', new_app_version: '10.8.0')

            expect(chart_file).to receive(:update_versions).with('0.1.0', '10.8.0')
            expect(version_mapping).to receive(:insert_version).with('0.1.0', '10.8.0')
            described_class.new(options)
          end

          it 'increases chart major when receiving an app major' do
            stub_versions(version: '0.0.1', app_version: 'master', new_app_version: '11.0.0')

            expect(chart_file).to receive(:update_versions).with('1.0.0', '11.0.0')
            expect(version_mapping).to receive(:insert_version).with('1.0.0', '11.0.0')
            described_class.new(options)
          end

          it 'increases chart version when receiving RC in a way that matches non-RC behaviour' do
            stub_versions(version: '0.0.1', app_version: 'master', new_app_version: '11.0.0-rc1')

            expect(chart_file).to receive(:update_versions).with('1.0.0', '11.0.0-rc1')
            expect(version_mapping).not_to receive(:insert_version)
            described_class.new(options)
          end
        end

        it 'increases chart patch when receiving an app patch' do
          stub_versions(version: '0.0.1', app_version: '10.8.0', new_app_version: '10.8.1')

          expect(chart_file).to receive(:update_versions).with('0.0.2', '10.8.1')
          expect(version_mapping).to receive(:insert_version).with('0.0.2', '10.8.1')
          described_class.new(options)
        end

        it 'increases chart minor when receiving an app minor' do
          stub_versions(version: '0.0.1', app_version: '10.7.5', new_app_version: '10.8.1')

          expect(chart_file).to receive(:update_versions).with('0.1.0', '10.8.1')
          expect(version_mapping).to receive(:insert_version).with('0.1.0', '10.8.1')
          described_class.new(options)
        end

        it 'increases chart major when receiving an app major' do
          stub_versions(version: '0.0.1', app_version: '10.8.5', new_app_version: '11.1.5')

          expect(chart_file).to receive(:update_versions).with('1.0.0', '11.1.5')
          expect(version_mapping).to receive(:insert_version).with('1.0.0', '11.1.5')
          described_class.new(options)
        end

        it 'completely chart version changes when app version has only changed by RC' do
          stub_versions(version: '0.0.1', app_version: '11.0.0-rc1', new_app_version: '11.0.0-rc2')

          expect(chart_file).to receive(:update_versions).with('0.0.1', '11.0.0-rc2')
          expect(version_mapping).not_to receive(:insert_version)
          described_class.new(options)
        end
      end
    end
  end
end

def stub_versions(new_version: nil, version: '0.0.1', new_app_version: nil, app_version: '0.0.1', branch: nil, auto_deploy: false)
  options.chart_version = Version.new(new_version) if new_version
  options.app_version = Version.new(new_app_version) if new_app_version
  options.auto_deploy = auto_deploy

  allow(chart_file).to receive(:version).and_return(Version.new(version)) if version
  allow(chart_file).to receive(:app_version).and_return(Version.new(app_version)) if app_version
  allow(chart_file).to receive(:update_versions) do | chart_ver, app_ver |
    allow(chart_file).to receive(:version).and_return(Version.new(chart_ver)) if chart_ver
    allow(chart_file).to receive(:app_version).and_return(Version.new(app_ver)) if app_ver
  end

  allow(version_mapping).to receive(:finalize).and_return(true)

  allow_any_instance_of(described_class).to receive(:branch).and_return(branch)
end
