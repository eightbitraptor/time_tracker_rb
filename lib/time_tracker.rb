# frozen_string_literal: true

require 'zeitwerk'
require 'subcommand'

class CustomInflector < Zeitwerk::Inflector
  def camelize(basename, _abspath)
    case basename
    when 'cli'
      'CLI'
    else
      super
    end
  end
end

loader = Zeitwerk::Loader.for_gem
loader.setup
loader.inflector = CustomInflector.new

module TimeTracker
  VERSION = '0.1.0'
  APP_NAME = 'time_tracker'
end
