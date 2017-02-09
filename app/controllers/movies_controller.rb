class MoviesController < ApplicationController	
	require 'pirate_bay/base.rb'
	before_action :set_current_page
	def index
		term = params[:term]
		if term.nil?
			# @current_page = '1'
			begin
				puts 'current_page : ' + @current_page
				minimum_rating = params[:minimum_rating].nil? ? '8' : params[:minimum_rating]
				sort_by = params[:sort_by].nil? ? 'seeds' : params[:sort_by]
				puts 'SORT BY : ' + sort_by
				with_images = 'true'
				order_by = params[:order_by].nil? ? 'desc' : params[:order_by]
				limit = '50'
				response = HTTParty.get('https://yts.ag/api/v2/list_movies.json?minimum_rating='+minimum_rating+'&sort_by='+sort_by+'&with_images='+with_images+'&order_by='+order_by+'&limit='+limit+'&page='+@current_page)
				json = response.body
				# @results = json.paginate :current_page => params[:current_page], :per_current_page => 20
				@result = JSON.parse(json)

				puts @result
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
			rescue
				@movies = []
				@total_pages = 1
			end
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
		else
			begin
				response = HTTParty.get('https://yts.ag/api/v2/list_movies.json?query_term=' + params[:term] + '&sort_by=title&order_by=asc' + '&page='+@current_page)
				@result = JSON.parse(response.body)
				@movies = []
				@total_pages = 1
				if @result['status'] == 'ok' && @result['status_message'] == 'Query was successful'
					@result['data'].each do |data|
						if data[0] == 'movies'
							@movies = @movies + data[1]
						end
					end
				end
			rescue
				@movies = []
				@total_pages = 1
			end
			pirate_bays_searchs = PirateBay::Search.new(params[:term]).execute.to_json
			searchs = JSON.parse(pirate_bays_searchs)
			searchs.each_with_index do |torrent, i|
				if torrent['imdb'] != "" && torrent['seeds'] > 10
					movie = @movies.find{|movie| movie['imdb'] == torrent['imdb']}
					if movie.nil?
						i = Imdb::Movie.new(torrent['imdb'][2..-1])
						torrent['title'] = i.title
						torrent['rating'] = i.rating
						torrent['year'] = i.year
						torrent['medium_cover_image'] = i.poster
						torrent['languages'] = [{language: torrent['language'], magnet_link: torrent['magnet_link']}]
						@movies.push(torrent)
					else
						if @movies[@movies.index(movie)]['languages'].find{|l| l[:language] == torrent['language']}.nil?
							@movies[@movies.index(movie)]['languages'].push({language: torrent['language'], magnet_link: torrent['magnet_link']})
						end
					end
				end
			end
		end
		 # @movies = Post.paginate(:current_page => params[:current_page], :per_current_page => 20)
	end

	# POST /video/new
	def new
		response = RestClient.get("http://localhost:3001/download?magnet=#{params[:magnet_link]}")
		if JSON.parse(response.body)['ok']
		    movie = Movie.create(title: params[:title], description: 'Pirate_bay recherche', form: 'mp4', path: JSON.parse(response.body)['path'])
		    redirect_to movie_path(id: movie.id)
		else
			redirect_to root_path
		end
	end

	def show
		@video = Movie.find(params[:id])
	    if @video
	      if @video.translates.empty?
	        path = @video.path[1..-1]
	        file = Subdb::Video.new("public/" + path)
	        file_in_folder = path.split('/')[-1].split('.')[0]
	        trads = file.search
	        if trads
	          trads = trads.split(',')
	          trads.each do |trad|
	            text = file.download([trad])
	            File.open(File.join("public/trads/", file_in_folder + '-' + trad + '.srt'), 'w+') do |f|
	              f.write(text.force_encoding("UTF-8"))
	              Translate.create(path: file_in_folder + '-' + trad + '.srt', label: trad, video: @video)
	            end
	          end
	        end
	      end
	      @translates = @video.translates
	    else
	      redirect_to root_path
	    end
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