module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
    end

    private

    def find_verified_user
      if (user_id = cookies.encrypted[:user_id] || cookies.signed[:user_id])
        User.find_by(id: user_id)
      elsif env['warden'] && (u = env['warden'].user)
        u
      else
        reject_unauthorized_connection
      end
    end
  end
end
