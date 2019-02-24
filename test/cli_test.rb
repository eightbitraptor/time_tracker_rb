# frozen_string_literal: true

require 'test_helper'

module TimeTracker
  class CLITest < Minitest::Test
    def test_configured_correctly
      TimeTracker::CLI.run(nil)

      assert_equal(1, 1)
    end
  end
end
