class OmniauthCallbacksController < Devise::OmniauthCallbacksController
	
	def facebook
		begin
		    user = User.from_omniauth(request.env["omniauth.auth"])
		    if user.persisted?
		    	sign_in user
		      	redirect_to root_path
		    	set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
		    else
		    	session["devise.facebook_data"] = request.env["omniauth.auth"]
		    	redirect_to new_user_registration_url
		    end
	    rescue
			redirect_to root_path
		end
	end

	def marvin
		begin
		    user = User.from_omniauth(request.env["omniauth.auth"])
		    if user.persisted?
		      	sign_in user
		      	redirect_to root_path
		     	set_flash_message(:notice, :success, :kind => "42") if is_navigational_format?
		    else
		     	session["devise.marvin_data"] = request.env["omniauth.auth"].except("extra")
		      	redirect_to new_user_registration_url
		    end
		rescue
			redirect_to root_path
		end
	  end

	def twitter
		begin
		    user = User.from_omniauth(request.env["omniauth.auth"])
		    if user.persisted?
		      	sign_in user
		      	redirect_to root_path
		     	set_flash_message(:notice, :success, :kind => "Twitter") if is_navigational_format?
		    else
		     	session["devise.twitter_data"] = user.attributes#request.env["omniauth.auth"].except("extra")
		      	redirect_to new_user_registration_url
		    end
	    rescue
			redirect_to root_path
		end
	end

	def failure
	   	redirect_to root_path
	end
end
