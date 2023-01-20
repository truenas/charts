#!/usr/bin/env ruby
# frozen_string_literal: true

require 'uri'
require 'stringio'
require_relative 'manage_version'

class TagAutoDeploy
  GIT_NAME = 'GitLab Release Tools Bot'.freeze
  GIT_EMAIL = 'delivery-team+release-tools@gitlab.com'.freeze

  def initialize
    @tag = ENV['AUTO_DEPLOY_TAG']
    @repository_token = ENV['REPOSITORY_PAT']

    # CI provided
    @git_remote_url = ENV['CI_REPOSITORY_URL']
    @current_branch = ENV['CI_COMMIT_BRANCH']

    # optional
    @test = ENV.fetch('TEST', false)
  end

  def execute
    $stderr.puts("dry-run mode") if dry_run?

    configure_git

    manage_version

    commit_and_push
  end

  private

  def configure_git
    git('config', '--global', 'user.name', GIT_NAME)
    git('config', '--global', 'user.email', GIT_EMAIL)

    git('remote', 'set-url', 'origin', git_writable_remote_url)
  end

  def manage_version
    args = [
      '--app-version', @tag,
      '--auto-deploy',
      '--include-subcharts'
    ]

    args << '--dry-run' if dry_run?

    options = VersionOptionsParser.parse(args)
    VersionUpdater.new(options)
  end

  def commit_and_push
    git('commit', '-am', "Bump auto-deploy version to #{@tag}")
    git('tag', '-m', tag_message, @tag)
    git('push', 'origin', "HEAD:#{@current_branch}", '--tags')
  end

  def tag_message
    msg = StringIO.new
    msg.puts("Auto-deploy helm charts #{@tag}")

    prefix = 'AUTO_DEPLOY_COMPONENT_'
    start = prefix.size
    ENV.keys.select { |key| key.start_with?(prefix) }.each do |key|
      msg.write("\n#{key[start..-1]}: #{ENV[key]}")
    end

    msg.string
  end

  def git(*args)
    puts("Running => git #{args.join(' ')}")
    return if dry_run?

    exit(2) unless system('git', *args)
  end

  def dry_run?
    @test
  end

  def git_writable_remote_url
    remote = URI(@git_remote_url)
    remote.user = 'gitlab-ci-token'
    remote.password = @repository_token

    remote.to_s
  end
end

# Only auto-run when called as a script, and not included as a lib
if $0 == __FILE__
  unless ENV.key?('CI')
    $stderr.puts 'This script can only be run in CI'
    exit(1)
  end

  TagAutoDeploy.new.execute
end
