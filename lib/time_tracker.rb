# frozen_string_literal: true

require 'subcommand'

require_relative('time_tracker/cli')
require_relative('time_tracker/data_location.rb')

module TimeTracker
  VERSION = '0.1.0'
  APP_NAME = 'time_tracker'
end
