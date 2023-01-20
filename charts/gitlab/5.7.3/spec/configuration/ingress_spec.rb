require 'spec_helper'
require 'helm_template_helper'
require 'yaml'
require 'hash_deep_merge'

describe 'GitLab Ingress configuration(s)' do
  def get_paths(template, ingress_name)
    template.dig("Ingress/#{ingress_name}", 'spec', 'rules', 0, 'http', 'paths')
  end

  def get_api_version(template, ingress_name)
    template.dig("Ingress/#{ingress_name}", 'apiVersion')
  end

  def get_ingress_class_name(template, ingress_class_name)
    template.dig("IngressClass/#{ingress_class_name}", 'metadata', 'name')
  end

  def get_ingress_class_annotation(template, ingress_name)
    template.dig("Ingress/#{ingress_name}", 'metadata', 'annotations', 'kubernetes.io/ingress.class')
  end

  def get_ingress_class_spec(template, ingress_name)
    template.dig("Ingress/#{ingress_name}", 'spec', 'ingressClassName')
  end

  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
    ))
  end

  let(:ingress_names) do
    %w[
      test-grafana-app
      test-gitlab-pages
      test-kas
      test-webservice-default
      test-webservice-default-smartcard
      test-minio
      test-registry
    ]
  end

  let(:enable_all_ingress) do
    default_values.deep_merge(YAML.safe_load(%(
      global:
        appConfig:
          smartcard:
            enabled: true
        minio:
          enabled: true
        pages:
          enabled: true
        grafana:
          enabled: true
        kas:
          enabled: true
      registry:
        enabled: true
    )))
  end

  it 'All Ingress are tested' do
    template = HelmTemplate.new(enable_all_ingress)
    expect(template.exit_code).to eq(0)

    all_ingress = template.resources_by_kind("Ingress").keys
    all_ingress.map! { |item| item.split('/')[1] }
    expect(all_ingress.sort.join(',')).to eq(ingress_names.sort.join(','))
  end

  describe 'global.ingress.path' do
    context 'default (/)' do
      it 'populates /' do
        template = HelmTemplate.new(enable_all_ingress)
        expect(template.exit_code).to eq(0)

        ingress_names.each do |ingress_name|
          paths = get_paths(template, ingress_name)
          paths.each do |p|
            expect(p["path"]).to end_with('/')
          end
        end
      end
    end

    context 'asterisk (/*)' do
      let(:asterisk) do
        enable_all_ingress.deep_merge(YAML.safe_load(%(
          global:
            ingress:
              path: /*
        )))
      end

      it 'populates /*' do
        template = HelmTemplate.new(asterisk)
        expect(template.exit_code).to eq(0)

        ingress_names.each do |ingress_name|
          paths = get_paths(template, ingress_name)
          paths.each do |p|
            expect(p["path"]).to end_with('/*')
          end
        end
      end
    end

    context 'invalid (/bogus)' do
      let(:bogus) do
        enable_all_ingress.deep_merge(YAML.safe_load(%(
          global:
            ingress:
              path: /bogus
        )))
      end

      it 'fails due to gitlab.webservice.ingress.requireBasePath' do
        template = HelmTemplate.new(bogus)
        expect(template.exit_code).not_to eq(0)
      end
    end

    context 'smartcard' do
      let(:smartcard) do
        default_values.deep_merge(YAML.safe_load(%(
          global:
            appConfig:
              smartcard:
                enabled: true
          gitlab:
            webservice:
              deployments:
                default:
                  ingress:
                    path: /default
                root:
                  ingress:
                    path: /
        )))
      end

      it 'does not create a smartcard ingress for non-root path' do
        template = HelmTemplate.new(smartcard)
        expect(template.exit_code).to eq(0)

        expect(template.dig("test-webservice-default-smartcard", 'spec')).to be_falsey
      end

      it 'uses the Webservice deployment with the root path as the backend service' do
        template = HelmTemplate.new(smartcard)
        expect(template.exit_code).to eq(0)

        paths = get_paths(template, "test-webservice-root-smartcard")
        paths.each do |p|
          expect(p["backend"]["serviceName"]).to eq("test-webservice-root")
        end
      end
    end
  end

  describe 'api version' do
    let(:ingress_class_specified) do
      enable_all_ingress.deep_merge(YAML.safe_load(%(
        global:
          ingress:
            class: fakeclass
      )))
    end

    let(:api_version_specified) do
      enable_all_ingress.deep_merge(YAML.safe_load(%(
        global:
          ingress:
            apiVersion: global/v0beta0
        gitlab:
          webservice:
            deployments:
              default:
                ingress:
                  path: /
                  apiVersion: local/v0beta0
      )))
    end

    context 'when not specified (without cluster connection)' do
      it 'sets default version (extensions/v1beta1)' do
        template = HelmTemplate.new(ingress_class_specified)
        expect(template.exit_code).to eq(0)

        ingress_names.each do |ingress_name|
          api_version = get_api_version(template, ingress_name)
          ingress_class_annotation = get_ingress_class_annotation(template, ingress_name)
          ingress_class_spec = get_ingress_class_spec(template, ingress_name)
          expect(api_version).to eq("extensions/v1beta1")
          expect(ingress_class_annotation).to eq('fakeclass')
          expect(ingress_class_spec).to be_nil
        end
      end
    end

    context 'when not specified (with cluster connection)' do
      it 'sets highest cluster-supported version' do
        api_versions_args = "--api-versions=networking.k8s.io/v1beta1/Ingress --api-versions=networking.k8s.io/v1/Ingress"
        template = HelmTemplate.new(ingress_class_specified, 'test', api_versions_args)
        expect(template.exit_code).to eq(0)

        ingress_names.each do |ingress_name|
          api_version = get_api_version(template, ingress_name)
          ingress_class_annotation = get_ingress_class_annotation(template, ingress_name)
          ingress_class_spec = get_ingress_class_spec(template, ingress_name)
          expect(api_version).to eq('networking.k8s.io/v1')
          expect(ingress_class_annotation).to be_nil
          expect(ingress_class_spec).to eq('fakeclass')
        end
      end
    end

    context 'when specified' do
      it 'sets proper API version' do
        template = HelmTemplate.new(api_version_specified)
        expect(template.exit_code).to eq(0)

        ingress_names.each do |ingress_name|
          api_version = get_api_version(template, ingress_name)

          if ingress_name.include? "webservice"
            expect(api_version).to eq("local/v0beta0")
          else
            expect(api_version).to eq("global/v0beta0")
          end
        end
      end
    end

    context 'when using ingress with networking.k8s.io/v1beta1 API' do
      it 'does not set ingressClassName resource' do
        api_version = enable_all_ingress.deep_merge(YAML.safe_load(%(
            global:
              ingress:
                apiVersion: networking.k8s.io/v1beta1
          )))

        template = HelmTemplate.new(api_version)
        expect(template.exit_code).to eq(0)

        ingress_names.each do |ingress_name|
          class_resource = template.dig("Ingress/#{ingress_name}", 'spec', 'ingressClassName')
          expect(class_resource).to eq(nil)
        end
      end

      it 'sets ingress-class annotation' do
        api_version = enable_all_ingress.deep_merge(YAML.safe_load(%(
            global:
              ingress:
                apiVersion: networking.k8s.io/v1beta1
          )))

        template = HelmTemplate.new(api_version)
        expect(template.exit_code).to eq(0)

        ingress_names.each do |ingress_name|
          annotation = template.dig("Ingress/#{ingress_name}", 'metadata', 'annotations', 'kubernetes.io/ingress.class')
          expect(annotation).to eq('test-nginx')
        end
      end
    end

    context 'when using ingress with networking.k8s.io/v1 API' do
      it 'sets ingressClassName resource' do
        api_version = enable_all_ingress.deep_merge(YAML.safe_load(%(
            global:
              ingress:
                apiVersion: networking.k8s.io/v1
          )))

        template = HelmTemplate.new(api_version)
        expect(template.exit_code).to eq(0)

        ingress_names.each do |ingress_name|
          class_resource = template.dig("Ingress/#{ingress_name}", 'spec', 'ingressClassName')
          expect(class_resource).to eq('test-nginx')
        end
      end

      it 'does not set ingress-class annotation' do
        api_version = enable_all_ingress.deep_merge(YAML.safe_load(%(
            global:
              ingress:
                apiVersion: networking.k8s.io/v1
          )))

        template = HelmTemplate.new(api_version)
        expect(template.exit_code).to eq(0)

        ingress_names.each do |ingress_name|
          annotation = template.dig("Ingress/#{ingress_name}", 'metadata', 'annotations', 'kubernetes.io/ingress.class')
          expect(annotation).to eq(nil)
        end
      end
    end
  end

  describe 'ingress class name' do
    let(:ingress_class_specified) do
      default_values.deep_merge(YAML.safe_load(%(
        global:
          ingress:
            class: specified
      )))
    end

    context 'default' do
      it 'populates the default name' do
        template = HelmTemplate.new(default_values)
        expect(template.exit_code).to eq(0)

        expected_name = 'test-nginx'
        name = get_ingress_class_name(template, expected_name)
        expect(name).to eq(expected_name)
      end
    end

    context 'specified' do
      it 'populates the specified name' do
        template = HelmTemplate.new(ingress_class_specified)
        expect(template.exit_code).to eq(0)

        expected_name = 'specified'
        name = get_ingress_class_name(template, expected_name)
        expect(name).to eq(expected_name)
      end
    end
  end
end
