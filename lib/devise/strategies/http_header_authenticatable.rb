require 'devise/strategies/http_header_authenticatable'

module Devise
  module Strategies
    class HttpHeaderAuthenticatable < ::Devise::Strategies::Base

      include Behaviors::HttpHeaderAuthenticatableBehavior

      # Called if the user doesn't already have a rails session cookie
      def valid?
        valid_user?(request.headers)
      end

      def authenticate!
        user = remote_user(request.headers)
        if user.present?
          STDERR.puts "AHOY AUTH #{user}"
          u = User.find_by_email(user)
          if u.nil?
           u = User.create(email: user)
           # u.populate_attributes
          end
          success!(u)
        else
          fail!
        end
      end

    end
  end
end

Warden::Strategies.add(:http_header_authenticatable, Devise::Strategies::HttpHeaderAuthenticatable)
