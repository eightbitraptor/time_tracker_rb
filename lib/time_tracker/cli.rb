# frozen_string_literal: true

module TimeTracker
  class CLI
    include Subcommands

    def self.run
      new.parse
    end

    def initialize
      commands.each do |name, map|
        command(name) do |opts|
          opts.description = map.fetch(:desc)
        end
      end

      # ARGV Parsing is part of opt_parse() provided by subcommand
      @command = opt_parse().to_sym
    end

    def parse
      commands
        .fetch(@command)
        .fetch(:method)
        .call()
    end

    private

    def commands
      {
        start: {
          desc: 'Start a new tracking session',
          method: SessionManager.method(:start_session),
        },
        stop: {
          desc: 'Stop the currently active session',
          method: SessionManager.method(:stop_active_session),
        },
      }
    end
  end
end
