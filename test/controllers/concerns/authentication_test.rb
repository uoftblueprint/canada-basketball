require "test_helper"

class AuthenticationTest < ActiveSupport::TestCase
  class Harness
    def self.before_action(*) = nil
    def self.helper_method(*) = nil

    include Authentication

    attr_reader :session, :redirect

    delegate :t, to: I18n

    def initialize(session = {})
      @session = session
    end

    def login_path = "/login"

    def redirect_to(path, flash:)
      @redirect = { path: path, flash: flash }
    end
  end

  %i[manager analyst camp logged_out].each do |identity|
    test "require_manager checks #{identity} access" do
      auth = authentication_for(identity)

      auth.send(:require_manager)

      if identity == :manager
        assert_nil auth.redirect
      else
        assert_denied auth, I18n.t("authentication.require_manager")
      end
    end

    test "require_analyst checks #{identity} access" do
      auth = authentication_for(identity)

      auth.send(:require_analyst)

      if %i[manager analyst].include?(identity)
        assert_nil auth.redirect
      else
        assert_denied auth, I18n.t("authentication.require_analyst")
      end
    end

    test "role predicates identify #{identity}" do
      auth = authentication_for(identity)

      assert_equal identity == :manager, auth.send(:logged_in_as_manager?)
      assert_equal identity == :analyst, auth.send(:logged_in_as_analyst?)
    end
  end

  %i[require_manager require_analyst].each do |guard|
    test "#{guard} rejects a deleted admin" do
      admin = create(:admin)
      auth = Harness.new(identity: { "type" => "admin", "id" => admin.id })
      admin.destroy!

      auth.send(guard)

      assert_denied auth, I18n.t("authentication.#{guard}")
    end
  end

  private

  def authentication_for(identity)
    case identity
    when :manager, :analyst
      admin = create(:admin, identity)
      Harness.new(identity: { "type" => "admin", "id" => admin.id })
    when :camp
      camp = create(:camp)
      Harness.new(identity: { "type" => "camp", "id" => camp.id })
    else
      Harness.new
    end
  end

  def assert_denied(auth, message)
    assert_equal({ path: "/login", flash: { error: message } }, auth.redirect)
  end
end
