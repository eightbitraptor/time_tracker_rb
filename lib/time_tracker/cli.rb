# frozen_string_literal: true

module TimeTracker
  class CLI
    def self.run(args)
      new(args).parse
    end

    def initialize(args)
      puts args
    end

    def parse
    end
  end
end
