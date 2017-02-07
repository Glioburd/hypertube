class ApplicationController < ActionController::Base
	protect_from_forgery with: :exception
	before_action :configure_permitted_parameters, if: :devise_controller?
	before_action :set_locale

  	def set_locale
  		I18n.locale = params[:locale] || I18n.default_locale
  		Rails.application.routes.default_url_options[:locale]= I18n.locale
    	#I18n.locale = current_user.try(:locale) || I18n.default_locale
  	end

	protected

	def configure_permitted_parameters
		devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :firstname, :login, :email, :password, :avatar) }
		devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :firstname, :login, :email, :password, :current_password, :avatar) }
	end
		
	def after_sign_in_path_for(resource)
		request.env['omniauth.origin'] || root_path
	end

end
