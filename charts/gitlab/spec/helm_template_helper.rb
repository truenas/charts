require 'yaml'
require 'open3'

class HelmTemplate
  def self.helm_version
    `helm version -c`.match('Ver(sion)?:"v(\d)\.')[2]
  end

  def self.helm_template_call(release_name: 'test', path: '-', namespace: nil, extra_args: nil)
    namespace_arg = namespace.nil? ? '' : "--namespace #{namespace}"

    case helm_version
    when "2" then
      "helm template -n #{release_name} -f #{path} #{namespace_arg} #{extra_args} ."
    when "3" then
      "helm template #{release_name} . -f #{path} #{namespace_arg} #{extra_args}"
    else
      # If we don't know the version of Helm, use `false` command
      "false"
    end
  end

  # This is the most common "default" as it is a hard requirement within defaults.
  def self.certmanager_issuer
    { "certmanager-issuer" => { "email" => "test@example.com" } }
  end

  def self.yaml_values(yaml_str)
    (YAML.safe_load(yaml_str) || {}).merge!(HelmTemplate.certmanager_issuer)
  end

  # Parses the specified YAML string and renders the template with it.
  def self.from_string(yaml_str = '')
    HelmTemplate.new(HelmTemplate.yaml_values(yaml_str))
  end

  # Reads the specified YAML file and renders the template with it.
  def self.from_file(file_path)
    HelmTemplate.from_string(
      File.read(file_path))
  end

  attr_reader :mapped

  def initialize(values, release_name = 'test', extra_args = '')
    template(values, release_name, extra_args)
  end

  def namespace
    stdout, stderr, exit_code = Open3.capture3("kubectl config view --minify --output 'jsonpath={..namespace}'")

    return 'default' unless exit_code != 0

    stdout.strip
  end

  def template(values, release_name = 'test', extra_args = '')
    @values  = values
    result = Open3.capture3(self.class.helm_template_call(namespace: 'default', release_name: release_name, extra_args: extra_args),
                            chdir: File.join(__dir__,  '..'),
                            stdin_data: YAML.dump(values))
    @stdout, @stderr, @exit_code = result
    # handle common failures when helm or chart not setup properly
    case @exit_code
    when 256
      fail "Chart dependencies not installed, run 'helm dependency update'" if @stderr.include? 'found in Chart.yaml, but missing in charts/ directory'
    end

    # load the complete output's YAML documents into an array
    yaml = YAML.load_stream(@stdout)
    # filter out any empty YAML documents (nil)
    yaml.select!{ |x| !x.nil? }
    # create an indexed Hash keyed on Kind/metdata.name
    @mapped = yaml.to_h  { |doc|
      [ "#{doc['kind']}/#{doc['metadata']['name']}" , doc ]
    }
  end

  def dig(*args)
    @mapped.dig(*args)
  end

  def volumes(item)
    @mapped.dig(item,'spec','template','spec','volumes')
  end

  def labels(item)
    @mapped.dig(item,'metadata','labels')
  end

  def template_labels(item)
    # only one of the following should return results
    @mapped.dig(item, 'spec', 'template', 'metadata', 'labels') ||
      @mapped.dig(item, 'spec', 'jobTemplate', 'spec', 'template', 'metadata', 'labels')
  end

  def annotations(item)
    @mapped.dig(item, 'metadata', 'annotations')
  end

  def template_annotations(item)
    # only one of the following should return results
    @mapped.dig(item, 'spec', 'template', 'metadata', 'annotations') ||
      @mapped.dig(item, 'spec', 'jobTemplate', 'spec', 'template', 'metadata', 'annotations')
  end

  def find_volume(item, volume_name)
    volumes = volumes(item)
    volumes.keep_if { |volume| volume['name'] == volume_name }
    volumes[0]
  end

  def get_projected_secret(item, mount, secret)
    # locate first instance of projected secret by name
    secrets = find_volume(item,mount)
    secrets['projected']['sources'].keep_if do |s|
      s['secret']['name'] == secret if s.has_key?('secret')
    end

    return unless secrets['projected']['sources'].length == 1

    secrets['projected']['sources'][0]['secret']
  end

  def find_projected_secret(item, mount, secret)
    secret = get_projected_secret(item,mount,secret)
    !secret.nil?
  end

  def find_projected_secret_key(item, mount, secret, key)
    secret = get_projected_secret(item,mount,secret)

    result = nil

    if secret&.has_key?('items')

      secret['items'].each do |i|
        if i['key'] == key
          result = i
          break
        end
      end

    end

    result
  end

  def find_volume_mount(item, container_name, volume_name, init = false)
    find_container(item, container_name, init)
      &.dig('volumeMounts')
      &.find { |volume| volume['name'] == volume_name }
  end

  def find_container(item, container_name, init = false)
    containers = init ? 'initContainers' : 'containers'

    dig(item, 'spec', 'template', 'spec', containers)
      &.find { |container| container['name'] == container_name }
  end

  def env(item, container_name, init = false)
    find_container(item, container_name, init)
      &.dig('env')
  end

  def projected_volume_sources(item,volume_name)
    find_volume(item,volume_name)
      &.dig('projected','sources')
  end

  def resources_by_kind(kind)
    @mapped.select{ |key, hash| hash['kind'] == kind }
  end

  def exit_code()
    @exit_code.to_i
  end

  def stderr()
    @stderr
  end

  def values()
    @values
  end
end
