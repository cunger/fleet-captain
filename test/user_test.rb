ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require_relative '../app/users'

class UserTest < Minitest::Test
  def setup
    @users = FleetCaptain::Users.new
    @user  = FleetCaptain::User.new('test', '1234')
  end

  def test_user_name_and_password
    assert_equal 'test', @user.name
    assert_raises NoMethodError do @user.password end
  end

  def test_validate_password
    assert @user.validate('1234')
    assert_raises FleetCaptain::PasswordNotCorrect do
      @user.validate('5678')
    end
  end

  def test_user_is_signed_in
    assert @user.signed_in?
  end

  def test_guest_user_is_not_signed_in
    refute FleetCaptain::GuestUser.new.signed_in?
  end

  def test_adding_and_finding_a_user
    @users << @user
    assert_equal @user, @users.fetch(@user.name)
    assert_raises FleetCaptain::NameAlreadyTaken do
      @users << FleetCaptain::User.new('test', '5678')
    end
  end

  def test_not_finding_a_user
    assert_raises FleetCaptain::UserNotFound do
      @users.fetch 'non-existing user'
    end
  end
end
