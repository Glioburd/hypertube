class UsersController < ApplicationController

	before_action :set_users, only: [:index]
	before_action :set_user, only: [:show]

	def index
		
	end

	def show
	end

	private

	def set_users
		@users = User.all
	end

	def set_user
		@user = User.where(login: params[:login]).first
	end
end