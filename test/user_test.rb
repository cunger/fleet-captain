ENV['RACK_ENV'] = 'test'
ENV['DIR'] = File.expand_path(File.dirname(__FILE__))

require 'bcrypt'
require 'minitest/autorun'
require_relative '../app/users'

class UserTest < Minitest::Test
  def setup
    @users = FleetCaptain::Users.new
    @user  = FleetCaptain::User.new('gary', BCrypt::Password.create('anderson'))
  end

  def test_users
    assert_equal @user, @users.fetch('gary')
  end

  def test_user_name_and_password
    assert_equal 'gary', @user.name
    assert_raises NoMethodError do @user.password end
  end

  def test_validate_password
    assert @user.validate('anderson')
    assert_raises FleetCaptain::PasswordNotCorrect do
      @user.validate('180')
    end
  end

  def test_user_is_signed_in
    assert @user.signed_in?
  end

  def test_guest_user_is_not_signed_in
    refute FleetCaptain::GuestUser.new.signed_in?
  end

  def test_adding_a_new_user
    new_user = FleetCaptain::User.new('peter', '180')
    @users << new_user
    assert_equal new_user, @users.fetch(new_user.name)
  end

  def test_adding_an_already_existing_user
    assert_raises FleetCaptain::NameAlreadyTaken do
      @users << FleetCaptain::User.new('gary', '180')
    end
  end

  def test_not_finding_a_user
    assert_raises FleetCaptain::UserNotFound do
      @users.fetch 'non-existing user'
    end
  end
end
