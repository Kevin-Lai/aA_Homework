class User < ApplicationRecord
    validates :email, presence: true
    validates :password_digest, length: {minimum: 6}, allow_nil: true
    validates :session_token, presence: true, uniqueness: true
    
    attr_reader :password
    after_initialize :ensure_session_token

    # def self.generate_session_token
    #     self.session_token = 
    # end

    def self.find_by_credentials(email, password)
        @user = User.find_by(email: email)
        if @user && @user.is_password?(password)
            return @user
        else
            return nil
        end
    end

    def self.reset_session_token!
        self.session_token = SecureRandom::urlsafe_base64(16)
        # update db with new session token
        self.save!
        # return the new session token
        self.session_token
    end

    def ensure_session_token
        self.session_token ||= SecureRandom::urlsafe_base64(16)
    end

    def password=(password)
        @password = password
        self.password_digest = BCrypt::Password.create(password)
    end

    def is_password?(password)
        BCrypt::Password.new(self.password_digest).is_password?(password)
    end

end