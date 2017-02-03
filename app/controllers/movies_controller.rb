class MoviesController < ApplicationController	
	def index
		param = params[:term]
		if !param
			response = HTTParty.get('https://yts.ag/api/v2/list_movies.json?minimum_rating=8.2&sort_by=seeds&with_images=true&order_by=desc&limit=50&page=1')
			json = response.body
			# @results = json.paginate :page => params[:page], :per_page => 20
			@result = JSON.parse(json)
			@result.each do |info|
				if info[0] == 'movies'
					puts info[1]
				end
			end
			# @movies = @result['data']['movies']['title']
		end
		 # @movies = Post.paginate(:page => params[:page], :per_page => 20)
	end

	def show
	end
	
end