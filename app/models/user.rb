class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable, :omniauth_providers => [:marvin, :facebook, :twitter]
  mount_uploader :avatar, AvatarUploader
  validates_uniqueness_of :login
  
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
          user.login = auth.info.nickname
          user.imageOauthUrl = auth.info.image.gsub("_normal", "")
          user.firstname = auth.info.name
        end
        if auth.provider == 'marvin'
          user.email = auth.info.email
          user.password = Devise.friendly_token[0,20]
          user.name = auth.info.name
          user.login = auth.info.nickname
          user.imageOauthUrl = auth.info.image + "?width=600"
          user.firstname = auth.info.name
        end
        if auth.provider == 'facebook'
          user.email = auth.info.email
          user.password = Devise.friendly_token[0,20]
          user.name = auth.info.last_name
          user.login = auth.info.first_name
          user.imageOauthUrl = auth.info.image + "?width=600"
          user.firstname = auth.info.first_name
        end
      end
    end
  end
end
