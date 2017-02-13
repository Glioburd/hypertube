class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:marvin, :facebook, :twitter]
  mount_uploader :avatar, AvatarUploader
  validates_uniqueness_of :login
  validate :password_complexity

  def password_complexity
    if password.present? and not password.match(/^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)./)
      errors.add :password, "must include at least one lowercase letter, one uppercase letter, and one digit"
    end
  end

  def update_with_password(params, *options)
    current_password = params.delete(:current_password)

    if params[:password].blank?
      params.delete(:password)
      params.delete(:password_confirmation) if params[:password_confirmation].blank?
    end

    result = if params[:password].blank? || valid_password?(current_password)
      update_attributes(params, *options)
    else
      self.assign_attributes(params, *options)
      self.valid?
      self.errors.add(:current_password, current_password.blank? ? :blank : :invalid)
      false
    end

    clean_up_passwords
    result
  end

  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def self.from_omniauth(auth)
    if !where(email: auth.info.email).empty?
      user = where(email: auth.info.email).first
      user.provider = auth.provider
      user.uid = auth.uid
      user.save!
      user      
    else
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        if auth.provider == 'twitter'
          user.email = auth.info.nickname + "@twitter.com"
          user.password = Devise.friendly_token[0,20]
          user.name = auth.info.name
          o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
          user.login = auth.info.nickname
          user.imageOauthUrl = auth.info.image.gsub("_normal", "")
          user.firstname = auth.info.name
        end
        if auth.provider == 'marvin'
          user.email = auth.info.email
          user.password = Devise.friendly_token[0,20]
          user.name = auth.info.name
          o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
          user.login = auth.info.nickname
          user.imageOauthUrl = auth.info.image + "?width=600"
          user.firstname = auth.info.name
        end
        if auth.provider == 'facebook'
          user.email = auth.info.email
          user.password = Devise.friendly_token[0,20]
          user.name = auth.info.last_name
          o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
          user.login = auth.info.last_name
          user.imageOauthUrl = auth.info.image + "?width=600"
          user.firstname = auth.info.first_name
        end
      end
    end
  end
end
