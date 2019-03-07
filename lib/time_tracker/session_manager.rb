# frozen_string_literal: true

module TimeTracker
  class SessionManager
    class << self
      def start_session
        new().start_session
      end

      def stop_active_session
        new().stop_active_session
      end
    end

    def initialize
      @session_dao = SessionDAO.new
    end

    def stop_active_session
      @session_dao.stop_session
    end

    def start_session
      @session_dao.new_session(start_time: Time.now.utc)
    end
  end
end
