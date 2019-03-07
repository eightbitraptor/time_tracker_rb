# frozen_string_literal: true

require 'test_helper'

module TimeTracker
  class CLITest < Minitest::Test
    def setup
      @fake_session_manager = mock()

      SessionManager
        .stubs(:new)
        .returns(@fake_session_manager)
    end

    def test__cli_has_start_command
      ARGV << 'start'
      subject = TimeTracker::CLI.new

      @fake_session_manager.expects(:start_session)
      subject.parse
    end

    def test__cli_has_stop_command
      ARGV << 'stop'
      subject = TimeTracker::CLI.new

      @fake_session_manager.expects(:stop_active_session)
      subject.parse
    end

    def test__cli_non_existent_commands_warn_on_stdout_and_exits
      ARGV << 'trololololololol'

      stdout, _stderr = capture_subprocess_io do
        @error_code = assert_raises(SystemExit) do
          TimeTracker::CLI.new.parse
        end
      end

      # TODO: Check the semantics of this, exit 0 seems wrong. Is this
      # OptParse's fault or Subcomand's
      assert_equal(0, @error_code.status)
      assert_match(/Invalid command: trololololololol/, stdout)
    end
  end
end
