# frozen_string_literal: true

require 'test_helper'

module TimeTracker
  class SessionManagerTest < Minitest::Test
    def setup
      @fake_dao = mock()
    end

    def test__initialize_connects_to_the_database
      SessionDAO.expects(:new)

      SessionManager.new
    end

    def test__start_session_tells_the_dao_to_start_a_session
      now = Time.now
      Time.stubs(:now).returns(now)

      SessionDAO.stubs(:new).returns(@fake_dao)
      @fake_dao.expects(:new_session).with(start_time: now)

      SessionManager.new.start_session
    end

    def test__stop_active_session_tells_session_dao_to_stop_active_session
      SessionDAO.stubs(:new).returns(@fake_dao)
      @fake_dao.stubs(:stop_session)

      SessionManager.new.stop_active_session
    end
  end
end
