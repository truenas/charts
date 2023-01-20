require_relative 'version'

class VersionMapping
  class Document
    TABLE_HEADER = '| Chart version | GitLab version |'.freeze
    TABLE_DIVIDE = '|---------------|----------------|'.freeze

    def initialize(filepath)
      unless filepath && File.exist?(filepath)
        $stderr.puts "Version mapping documention must exist: #{filepath}"
        exit 1
      end

      @filepath = filepath

      $stdout.puts "Reading #{@filepath}"
      @document = File.read(@filepath).split("\n")

      unless @document.include?(TABLE_HEADER)
        $stderr.puts "Version mapping documention must contain table: #{filepath}"
        exit 1
      end
    end

    def table
      @table ||= extract_version_table
    end

    def write
      update_version_table
      $stdout.puts "Updating #{@filepath}"
      content = @document.join("\n")

      # Append a newline for docs linter to be happy
      content += "\n" unless content.end_with?("\n")

      File.write(@filepath, content)
    end

    private

    def extract_version_table
      @table = Table.new

      # find the table in the file
      @index_start = @document.find_index(TABLE_HEADER)
      # find the first blank line after the header, denoting end of table
      @index_end = @document.drop(@index_start).find_index('')

      table_content = @document.slice(@index_start, @index_end)

      # convert the table into a VersionMapping::Table
      # Note: drop(2) to dispose of TABLE_HEADER and TABLE_DIVIDE
      table_content.drop(2).each do |item|
        items = item.split('|').delete_if { |i| i == '' }
        @table.append(Version.new(items[0].strip), Version.new(items[1].strip))
      end

      @table
    end

    def update_version_table
      table_content = [TABLE_HEADER, TABLE_DIVIDE]

      table.sort!.each do |entry|
        table_content << "| #{entry[0]} | #{entry[1]} |"
      end

      @document[@index_start, @index_end] = table_content

      @index_end = table_content.count
    end
  end

  class Table
    include Enumerable

    def initialize
      @entries = []
    end

    def append(chart_version, app_version)
      chart_version = Version.new(chart_version) unless chart_version.instance_of? Version
      app_version = Version.new(app_version) unless app_version.instance_of? Version

      return unless chart_version.release? && app_version.release?

      @entries.delete_if { |item| item[0] == chart_version }
      @entries << [chart_version, app_version]
    end

    def sort!
      @entries.sort! { |a, b| b[0] <=> a[0] }
    end

    def each(&block)
      @entries.each(&block)
    end

    def count
      @entries.count
    end
  end

  # VersionMapping
  attr_reader :document

  def initialize(filepath)
    @document = Document.new(filepath)
  end

  def insert_version(chart_version, app_version)
    @document.table.append(chart_version, app_version)
  end

  def finalize
    @document.write
  end
end
