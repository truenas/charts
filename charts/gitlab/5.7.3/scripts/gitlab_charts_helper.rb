class GitLabChartsHelper
  class << self
    def supported_versions(count: 3)
      # Get release (non auto-deploy) tags in sorted order
      chart_release_tags = IO.popen(%w[git tag -l v* --sort=-v:refname], &:read)&.split("\n")
      return unless chart_release_tags

      ordered_tag_names = chart_release_tags.map { |tag| tag.delete('v') }
      latest_tag = nil
      supported_tags = []

      count.times do
        current_minor_series = latest_tag.nil? ? nil : latest_tag.split(".")[0..1].join(".")

        # latest_tag has been already handled. Remove all the tags in that
        # series and get the remaining. In the first pass, nothing has been
        # already handled, so the entire list of tags is considered
        ordered_tag_names = ordered_tag_names.reject { |tag| tag.start_with?(current_minor_series) } if current_minor_series

        # Reset latest_tag to the latest one in the remaining series
        latest_tag = ordered_tag_names.first
        supported_tags << latest_tag
      end

      supported_tags
    end
  end
end
