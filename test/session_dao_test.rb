# frozen_string_literal: true

require 'test_helper'
require 'tempfile'

module TimeTracker
  class SessionDAOTest < Minitest::Test
    def test__new_creates_sessions_table_when_it_doesnt_exist
      fake_db_file = Tempfile.new.path

      SessionDAO.new(fake_db_file)

      assert table_exists?(table_name: 'sessions', db: fake_db_file)
    end

    def test__new_doesnt_recreate_sessions_table_when_it_exists
      fake_db_file = Tempfile.new.path

      write_fake_sessions_table(fake_db_file)

      assert fake_data_not_overritten?(fake_db_file)
    end

    def test__new_session_when_no_active_session_creates_a_new_active_session
      fake_db_file = Tempfile.new.path
      now = Time.now.utc

      session = SessionDAO.new(fake_db_file)
        .new_session(start_time: now)

      assert session.active?
      assert_equal now.to_i, session.start_time.to_i
    end

    def test__new_session_when_a_session_is_active_raises
      fake_db_file = Tempfile.new.path

      create_active_session(fake_db_file)

      assert_raises SessionDAO::AlreadyActiveSession do
        SessionDAO.new(fake_db_file)
          .new_session(start_time: Time.now)
      end
    end

    def test__stop_session_when_there_is_no_active_session_raises
      fake_db_file = Tempfile.new.path

      assert_raises SessionDAO::NoActiveSession do
        SessionDAO.new(fake_db_file).stop_session
      end
    end

    def test__stop_session_when_there_is_an_active_session_stops_the_session
      fake_db_file = Tempfile.new.path
      create_active_session(fake_db_file)

      SessionDAO.new(fake_db_file).stop_session

      assert no_active_sessions?(fake_db_file)
    end

    private

    def no_active_sessions?(fake_db_file)
      conn = SQLite3::Database.new(fake_db_file)

      active_session_count = conn.query("SELECT count(*) from sessions
                                         WHERE stop_time IS NULL")

      active_session_count.next.first.zero?
    end

    def table_exists?(table_name:, db:)
      conn = SQLite3::Database.new(db)
      table_count = conn.query("SELECT count(*) AS c from sqlite_master
                                WHERE type='table'
                                AND name=?", [table_name])

      table_count.next.first.positive?
    end

    def write_fake_sessions_table(db_file)
      SQLite3::Database.new(db_file).tap do |db|
        db.execute('CREATE TABLE sessions (fake_col varchar(5))')
        db.execute('INSERT INTO sessions (fake_col) VALUES ("hello")')
      end
    end

    def fake_data_not_overritten?(db_file)
      conn = SQLite3::Database.new(db_file)
      results = conn.query("SELECT count(*) AS c from sessions
                            WHERE fake_col='hello'")

      results.next.first.positive?
    end

    def create_active_session(db_file)
      SessionDAO.new(db_file)

      conn = SQLite3::Database.new(db_file)
      conn.prepare('INSERT INTO sessions (start_time) VALUES ( ? )')
        .execute(Time.now.to_i)
    end
  end
end
