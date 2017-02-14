class CommentController < ApplicationController
	before_action :authenticate_user!

	def new
		if Movie.find(params[:comment][:id])
			Comment.create(user: current_user, movie: Movie.find(params[:comment][:id]), content: params[:comment][:content])
			render json: {ok: 1, comment: params[:comment][:content], user: current_user.login}
		else
			render json: {ok: 0}
		end
	end
end