# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/reporters'

module Minitest
  module Reporters
    class CustomReporter < SpecReporter
      def record_print_status(test)
        print(' ')
        print_colored_status(test)
        unless test.time.nil?
          time = format(' (%.2fs)', test.time)
          time = red { time } if test.time > 5.0
          print(time)
        end
        print('  ')
        print(test.name)
        puts
      end

      def print_colored_status(test)
        if test.passed?
          print(green { '✓' })
        elsif test.skipped?
          print(yellow { 'SKIP' })
        else
          print('✘')
        end
      end
    end
  end
end

reporter_options = { color: true, slow_count: 5 }
Minitest::Reporters.use!(
  Minitest::Reporters::CustomReporter.new(reporter_options)
)

require 'time_tracker'

require 'mocha/minitest'

Mocha::Configuration.prevent(:stubbing_non_existent_method)
