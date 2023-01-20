require 'spec_helper'
require 'helm_template_helper'
require 'yaml'

describe 'Redis configuration' do
  let(:default_values) do
    YAML.safe_load(%(
      certmanager-issuer:
        email: test@example.com
    ))
  end

  describe 'global.redis.password.enabled' do
    let(:values) do
      YAML.safe_load(%(
        global:
          redis:
            password:
              enabled: true
      )).merge(default_values)
    end

    context 'when true' do
      it 'populate password' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("redis/redis-password")
      end
    end

    context 'when false' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              password:
                enabled: false
        )).merge(default_values)
      end

      it 'do not populate password' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).not_to include("redis/redis-password")
      end
    end
  end

  describe 'Split Redis queues' do
    context 'When redis.install is true' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              cache:
                host: cache.redis
          redis:
            install: true
        )).merge(default_values)
      end

      it 'fails to template (checkConfig)' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).not_to eq(0)
      end
    end

    context 'When sub-queue does not define password' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              password:
                secret: rspec-resque
              cache:
                host: cache.redis
          redis:
            install: false
        )).merge(default_values)
      end

      it 'sub-queue inherits all of password from global.redis' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("redis/redis-password")
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("resque.redis")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("redis/cache-password")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("cache.redis")
        secret_mounts =  t.projected_volume_sources('Deployment/test-webservice-default','init-webservice-secrets').select { |item|
          item['secret']['name'] == 'rspec-resque'
        }
        expect(secret_mounts.length).to eq(2)
      end
    end

    context 'When sub-queue defines password.secret, but not password.enabled' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              password:
                secret: rspec-resque
              cache:
                host: cache.redis
                password:
                  secret: rspec-cache
          redis:
            install: false
        )).merge(default_values)
      end

      it 'sub-queue inherits from global' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        projected_volume = t.projected_volume_sources('Deployment/test-webservice-default','init-webservice-secrets')
        redis_mount =  projected_volume.select { |item| item['secret']['name'] == "rspec-resque" }
        cache_mount =  projected_volume.select { |item| item['secret']['name'] == "rspec-cache" }
        # check that it gets consumed
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("redis/redis-password")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("redis/cache-password")
        # check that they are individually mounted.
        expect(redis_mount.length).to eq(1)
        expect(cache_mount.length).to eq(1)
      end
    end

    context 'When sub-queue defines password.enabled true, and redis.password.enabled is false' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              password:
                enabled: false
                secret: rspec-resque
              cache:
                host: cache.redis
                password:
                  enabled: true
                  secret: rspec-cache
          redis:
            install: false
        )).merge(default_values)
      end

      it 'sub-queue uses password, global does not' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        projected_volume = t.projected_volume_sources('Deployment/test-webservice-default','init-webservice-secrets')
        redis_mount =  projected_volume.select { |item| item['secret']['name'] == "rspec-resque" }
        cache_mount =  projected_volume.select { |item| item['secret']['name'] == "rspec-cache" }
        # check that it gets consumed
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).not_to include("redis/redis-password")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("redis/cache-password")
        # check that they are individually mounted.
        expect(redis_mount.length).to eq(0)
        expect(cache_mount.length).to eq(1)
      end
    end

    context 'When sub-queue defines password.enabled false, and redis.password.enabled is true' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              password:
                enabled: true
                secret: rspec-resque
              cache:
                host: cache.redis
                password:
                  enabled: false
                  secret: rspec-cache
          redis:
            install: false
        )).merge(default_values)
      end

      it 'sub-queue does not use password, global does' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        projected_volume = t.projected_volume_sources('Deployment/test-webservice-default','init-webservice-secrets')
        redis_mount =  projected_volume.select { |item| item['secret']['name'] == "rspec-resque" }
        cache_mount =  projected_volume.select { |item| item['secret']['name'] == "rspec-cache" }
        # check that it gets consumed
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("redis/redis-password")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).not_to include("redis/cache-password")
        # check that they are individually mounted.
        expect(redis_mount.length).to eq(1)
        expect(cache_mount.length).to eq(0)
      end
    end

    context 'When sub-queue defines port, but not host' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              port: 6379
              cache:
                port: 9999
          redis:
            install: false
        )).merge(default_values)
      end

      it 'sub-queue uses port, global host' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        # check that it gets correct hosts & port are used
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("resque.redis:6379")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("resque.redis:9999")
      end
    end

    context 'When global and sub-queue defines Sentinels' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              port: 6379
              sentinels:
              - host: s1.resque.redis
                port: 26379
              - host: s2.resque.redis
                port: 26379
              cache:
                host: cache.redis
                sentinels:
                - host: s1.cache.redis
                  port: 26379
                - host: s2.cache.redis
                  port: 26379
          redis:
            install: false
        )).merge(default_values)
      end

      it 'separate sentinels are populated' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        # check that it they consumed only in sub-queue
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("sentinels:")
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).to include("s1.resque.redis")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("sentinels:")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("s1.cache.redis")
      end
    end

    context 'When only sub-queue defines Sentinels' do
      let(:values) do
        YAML.safe_load(%(
          global:
            redis:
              host: resque.redis
              port: 6379
              cache:
                host: cache.redis
                sentinels:
                - host: s1.cache.redis
                  port: 26379
                - host: s2.cache.redis
                  port: 26379
          redis:
            install: false
        )).merge(default_values)
      end

      it 'sub-queue sentinels are populated' do
        t = HelmTemplate.new(values)
        expect(t.exit_code).to eq(0)
        # check that it they consumed only in sub-queue
        expect(t.dig('ConfigMap/test-webservice','data','resque.yml.erb')).not_to include("sentinels:")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("sentinels:")
        expect(t.dig('ConfigMap/test-webservice','data','redis.cache.yml.erb')).to include("s1.cache.redis")
      end
    end
  end

  describe 'Generated Kubernetes object names' do
    context 'Helm release name does not include "redis"' do
      it 'Objects are suffixed with "-redis", references match' do
        # run template, default release name is 'test'
        t = HelmTemplate.new(default_values)
        expect(t.exit_code).to eq(0)
        # check that Services are -redis-master
        expect(t.dig('Service/test-master')).to be_falsey
        expect(t.dig('Service/test-redis-master')).to be_truthy
        # check resque.yml
        expect(t.dig('ConfigMap/test-toolbox','data','resque.yml.erb')).to include('test-redis-master')
      end
    end

    context 'Helm release name includes "redis"' do
      it 'Objects are suffixed without "-redis", references match' do
        # run template, pass release name with "redis" in it
        t = HelmTemplate.new(default_values,'redis-test')
        expect(t.exit_code).to eq(0)
        # check that Services are -master
        expect(t.dig('Service/redis-test-master')).to be_truthy
        expect(t.dig('Service/redis-test-redis-master')).to be_falsey
        # check resque.yml is pointing to the right service.
        expect(t.dig('ConfigMap/redis-test-toolbox','data','resque.yml.erb')).to include('redis-test-master')
      end
    end
  end
end
