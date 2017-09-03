module FleetCaptain

  class NameAlreadyTaken < RuntimeError ; end
  class UserNotFound < RuntimeError ; end
  class PasswordNotCorrect < RuntimeError ; end

  class Users
    def initialize
      @users = []
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

  class User
    attr_reader :name

    def initialize(name, password)
      @name = name
      @password = password
    end

    def validate(password)
      raise PasswordNotCorrect unless @password == password
      true
    end

    def signed_in?
      true
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
