require 'spec_helper'
require 'open-uri'

describe "Restoring a backup" do
  before(:all) do
    stdout, status = wait_for_dependencies
    fail stdout unless status.success?

    wait_until_app_ready
    ensure_backups_on_object_storage

    stdout, status = gitaly_purge_storage
    fail stdout unless status.success?

    stdout, status = restore_from_backup
    fail stdout unless status.success?

    # We run migrations once early to get the db into a place where we can set the runner token
    # Ignore errors, we will run the migrations again after the token
    run_migrations

    stdout, status = set_runner_token
    fail stdout unless status.success?

    stdout, status = run_migrations
    fail stdout unless status.success?

    stdout, status = enforce_root_password(ENV['GITLAB_PASSWORD']) if ENV['GITLAB_PASSWORD']
    fail stdout unless status.success?

    stdout, status = restart_webservice
    fail stdout unless status.success?

    # Wait for the site to come up after the restore/migrations
    wait_until_app_ready

    # Have the gitlab-runner re-register after the restore
    restart_gitlab_runner
  end

  describe 'Restored gitlab instance' do
    before { sign_in }

    it 'Home page should show projects' do
      visit '/'
      expect(page).to have_content 'Projects'
      expect(page).to have_content 'Administrator / testproject1'
    end

    it 'Navigating to testproject1 repo should work' do
      visit '/root/testproject1'
      expect(find('table[data-qa-selector="file_tree_table"]'))
        .to have_content('Dockerfile')
    end

    it 'Should have runner registered' do
      visit '/admin/runners'
      expect(page).to have_css('#content-body [data-testid^=\'runner-row-\']', minimum: 1)
    end

    it 'Issue attachments should load correctly' do
      visit '/root/testproject1/issues/1'

      image_selector = 'div.md > p > a > img.js-lazy-loaded'

      # Image has additional classes added by JS async
      wait(reload: false) do
        has_selector?(image_selector)
      end

      expect(page).to have_selector(image_selector)
      image_src = page.all(image_selector)[0][:src]
      URI.open(image_src) do |f|
        expect(f.status[0]).to eq '200'
      end
    end

    it 'Could pull image from registry' do
      stdout, status = Open3.capture2e("docker login #{registry_url} --username root --password #{ENV['GITLAB_PASSWORD']}")
      expect(status.success?).to be(true), "Login failed: #{stdout}"

      stdout, status = Open3.capture2e("docker pull #{registry_url}/root/testproject1/master:d88102fe7cf105b72643ecb9baf41a03070c9f1b")
      expect(status.success?).to be(true), "Pulling image failed: #{stdout}"
    end

  end

  describe 'Backups' do
    it 'Should be able to backup an identical tar' do
      stdout, status = backup_instance
      expect(status.success?).to be(true), "Error backing up instance: #{stdout}"

      object_storage.get_object(
        response_target: '/tmp/original_backup.tar',
        bucket: 'gitlab-backups',
        key: 'original_gitlab_backup.tar'
      )

      cmd = 'mkdir -p /tmp/original_backup && tar -xf /tmp/original_backup.tar -C /tmp/original_backup'
      stdout, status = Open3.capture2e(cmd)
      expect(status.success?).to be(true), "Error unarchiving original backup: #{stdout}"

      object_storage.get_object(
        response_target: '/tmp/test_generated_backup.tar',
        bucket: 'gitlab-backups',
        key: 'test-backup_gitlab_backup.tar'
      )
      cmd = 'mkdir -p /tmp/test_backup && tar -xf /tmp/test_generated_backup.tar -C /tmp/test_backup'
      stdout, status = Open3.capture2e(cmd)
      expect(status.success?).to be(true), "Error unarchiving generated backup: #{stdout}"

      Dir.glob("/tmp/original_backup/*") do |file|
        file_path = "/tmp/test_backup/#{File.basename(file)}"
        expect(File.exist?(file_path)).to be_truthy, "#{File.basename(file)} exists in original backup but not in test ( #{file_path} )"
        # extract every tar file
        if File.extname(file) == 'tar'
          cmd = "tar -xf #{file} -C /tmp/original_backup"
          stdout, status = Open3.capture2e(cmd)
          expect(status.success?).to be(true), "Error extracting tar #{file}: #{stdout}"

          f_name = file.gsub('original_backup', 'test_backup')
          cmd = "tar -xf #{f_name} -C /tmp/test_backup"
          stdout, status = Open3.capture2e(cmd)
          expect(status.success?).to be(true), "Error extracting tar #{f_name}: #{stdout}"
        end
      end

      Dir.glob("/tmp/original_backup/**/*") do |file|
        next if ['tar', '.gz'].include? File.extname(file)
        next if File.directory?(file)
        next if File.basename(file) == 'backup_information.yml'

        test_counterpart = file.gsub('original_backup', 'test_backup')

        expect(File.exist?(test_counterpart)).to be_truthy, "Expected #{test_counterpart} to exist"

        original_content = File.read(file)
        test_content = File.read(test_counterpart)

        # Strip the ref list header from bundle as its sort order may not be guaranteed
        if File.extname(file) == '.bundle'
          original_content = original_content.slice(original_content.index("PACK\u0000")..-1)
          test_content = test_content.slice(test_content.index("PACK\u0000")..-1)
        end

        expect(Digest::MD5.hexdigest(original_content)).to eq(Digest::MD5.hexdigest(test_content)),
          "Expected #{file} to equal #{test_counterpart}"
      end
    end
  end
end
