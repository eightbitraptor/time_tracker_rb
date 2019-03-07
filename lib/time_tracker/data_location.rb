# frozen_string_literal: true

require "rbconfig"

module TimeTracker
  class DataLocation
    BrokenConfig = Class.new(StandardError)

    def self.data_file
      new.data_file
    end

    def initialize
      @host_os = case RbConfig::CONFIG.fetch("host_os")
                 when /darwin/ then :macos
                 when /linux/ then :linux
                 end
    rescue KeyError
      raise BrokenConfig, "Cannot determine host os from RbConfig"
    end

    def data_file
      File.join(data_directory_root, "database.sqlite")
    end

    def data_directory_root
      ENV.fetch("XDG_DATA_HOME") { default_platform_data_dir }
    end

    def default_platform_data_dir
      platform_data_dir = case @host_os
                          when :macos then "Library/Application Support"
                          when :linux then ".local/share"
                          end

      File.expand_path(
        File.join(platform_data_dir, TimeTracker::APP_NAME),
        ENV.fetch("HOME")
      )
    end
  end
end
