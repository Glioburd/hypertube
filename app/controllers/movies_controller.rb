class MoviesController < ApplicationController	
	def index
		param = params[:term]
		if !param
			response = HTTParty.get('https://yts.ag/api/v2/list_movies.json?minimum_rating=6.2&sort_by=seeds&with_images=true&order_by=desc&limit=50&page=3')
			json = response.body
			@results = Post.paginate :page => params[:page]
			# @result = JSON.parse(json)
		end
		 # @movies = Post.paginate(:page => params[:page], :per_page => 20)
	end

	def show
	end
	
end