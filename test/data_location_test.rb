# frozen_string_literal: true

require 'test_helper'

module TimeTracker
  class DataLocationGenericTest < Minitest::Test
    def test__unable_to_determine_os_is_a_catastrophic_fail
      RbConfig::CONFIG
        .stubs(:fetch)
        .with('host_os')
        .raises(KeyError)

      assert_raises DataLocation::BrokenConfig do
        DataLocation.data_file
      end
    end
  end

  class DataLocationMacOSTest < Minitest::Test
    def setup
      RbConfig::CONFIG
        .stubs(:fetch)
        .with('host_os')
        .returns('darwinx86-64')

      @old_home = ENV['HOME']
      ENV['HOME'] = '/my-home'
    end

    def teardown
      ENV['HOME'] = @old_home
    end

    def test__data_location_uses_library_application_support
      assert_equal \
        '/my-home/Library/Application Support/time_tracker/database.sqlite',
        DataLocation.data_file
    end
  end

  class DataLocationLinuxTest < Minitest::Test
    def setup
      RbConfig::CONFIG
        .stubs(:fetch)
        .with('host_os')
        .returns('linux86-64')

      @old_home = ENV['HOME']
      @old_xdg = ENV['XDG_DATA_HOME']

      ENV['HOME'] = '/my-home'
      ENV['XDG_DATA_HOME'] = 'xdg-data-home'
    end

    def teardown
      ENV['HOME'] = @old_home
      ENV['XDG_DATA_HOME'] = @old_xdg
    end

    def test__data_location_respects_xdg_data_dir_when_set
      assert_equal 'xdg-data-home/database.sqlite', DataLocation.data_file
    end

    def test__data_location_defaults_to_dot_local
      ENV.delete('XDG_DATA_HOME')
      assert_equal \
        '/my-home/.local/share/time_tracker/database.sqlite',
        DataLocation.data_file
    end
  end
end
