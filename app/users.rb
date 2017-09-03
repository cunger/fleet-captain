ENV['DIR'] = File.expand_path(File.dirname(__FILE__))

require 'bcrypt'
require 'json'

module FleetCaptain

  class NameAlreadyTaken < RuntimeError ; end
  class UserNotFound < RuntimeError ; end
  class PasswordNotCorrect < RuntimeError ; end

  class Users
    def initialize
      json = JSON.parse File.read(ENV['DIR'] + '/users.json')
      @users = json.map { |name, pwd| User.new(name, pwd) }
    end

    def <<(new_user)
      already_taken? new_user.name
      @users << new_user
    end

    def fetch(name)
      @users.each do |user|
        return user if user.name == name
      end
      block_given? ? yield : raise(UserNotFound)
    end

    private

    def already_taken?(name)
      raise NameAlreadyTaken if @users.any? { |user| user.name == name }
    end
  end

  #
  # A user is uniquely identifiable by @name.
  #
  class User
    attr_reader :name

    def initialize(name, password)
      @name = name
      @password = password 
    end

    def validate(alleged_password)
      raise PasswordNotCorrect unless password == alleged_password
      true
    end

    def signed_in?
      true
    end

    def ==(other)
      name == other.name
    end

    private

    def password
      BCrypt::Password.new @password
    end
  end

  class GuestUser < User
    def initialize
      @name = 'guest'
    end

    def signed_in?
      false
    end
  end
end
