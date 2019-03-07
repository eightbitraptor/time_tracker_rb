require 'fileutils'

module TimeTracker
  class SessionDAO
    SessionAccessError   = Class.new(StandardError)
    AlreadyActiveSession = Class.new(StandardError)
    NoActiveSession      = Class.new(StandardError)

    class Session
      def initialize(start_time:, stop_time: nil)
        @start_time = start_time
        @stop_time = stop_time
      end

      def active?
        @stop_time.nil?
      end

      def start_time
        Time.at(@start_time).utc
      end

      def stop_time
        Time.at(@stop_time).utc
      end
    end

    def initialize(data_file = DataLocation.data_file)
      ensure_writable(data_file)
      @db_conn = SQLite3::Database.new(data_file)

      create_sessions_table
    end

    def new_session(start_time:)
      if active_session
        raise AlreadyActiveSession,
              'cannot create a session while a session is already active'
      end

      create_session(start_time.to_i) && active_session
    end

    def stop_session
      unless active_session
        raise NoActiveSession,
              'cannot stop a session as no session is active'
      end

      @db_conn
        .prepare('UPDATE sessions SET stop_time = ? WHERE stop_time IS NULL')
        .execute(Time.now.to_i)
    end

    private

    def active_session
      result_set = @db_conn.query('SELECT * FROM sessions
                                   WHERE stop_time IS NULL
                                   ORDER BY start_time DESC LIMIT 1')

      sessions = sessions_from_result_set(result_set)

      if sessions.length > 1
        fail SessionAccessError, 'More than one active session in progress'
      end

      sessions.first
    end

    def sessions_from_result_set(result_set)
      sessions = []
      result_set.each_hash do |row|
        sessions << Session.new(start_time: row['start_time'])
      end

      sessions
    end

    def create_session(start_time)
      @db_conn
        .prepare('INSERT INTO sessions (start_time) VALUES ( ? )')
        .execute(start_time)
    end

    def create_sessions_table
      @db_conn.execute(<<~SQL)
        CREATE TABLE IF NOT EXISTS sessions(
          start_time INTEGER,
          stop_time INTEGER
        )
      SQL
    end

    def ensure_writable(data_file)
      FileUtils.mkdir_p(File.dirname(data_file))
      FileUtils.touch(data_file)
    end
  end
end
