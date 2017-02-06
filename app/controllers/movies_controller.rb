class MoviesController < ApplicationController	

before_action :set_current_page

	def index
		term = params[:term]
		if term.nil?
			# @current_page = '1'
			puts 'current_page : ' + @current_page
			minimum_rating = '8.2'
			sort_by = 'seeds'
			with_images = 'true'
			order_by = 'desc'
			limit = '50'
			current_page = @current_page
			response = HTTParty.get('https://yts.ag/api/v2/list_movies.json?minimum_rating='+minimum_rating+'&sort_by='+sort_by+'&with_images='+with_images+'&order_by='+order_by+'&limit='+limit+'&page='+@current_page)
			json = response.body
			# @results = json.paginate :current_page => params[:current_page], :per_current_page => 20
			@result = JSON.parse(json)

			# puts @result
			# puts @result['data']['movies'].each do ||
			# @result['data']['movies'].each do |info|
			# 	puts info
			# end
			
			@movies_count = @result['data']['movie_count']
			puts 'Movie count : ' + @movies_count.to_s
			@limit = @result['data']['limit']
			puts 'Limit : ' + @limit.to_s
			@movies = @result['data']['movies']
			puts 'number of pages : ' + total_pages.to_s
			# @cover = @result['data']['medium_cover_image']
			# puts 'cover : ' + @cover
			# @title = @result['data']['title']
			# puts 'title : ' + @title
			# @year = @result['data']['year']
			# puts 'year : ' + @year.to_s
			# puts @movies.each
			# 	puts '******************************'
			# 	puts info
			# 	puts '******************************'

			# 	if info[0] == 'movies'
			# 		# puts '***' + info[1] + '***'
			# 	end
			# end
			# @movies = @result['data']['movies']['title']
		end
		 # @movies = Post.paginate(:current_page => params[:current_page], :per_current_page => 20)
	end

	def show
	end
	
	private

	def set_current_page
		if !params[:page]
			@current_page = '1'
		else
			@current_page = params[:page]
		end
	end

	def total_pages
		@total_pages = (@movies_count.to_f / @limit.to_f).ceil
	end

end