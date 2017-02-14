class MoviesController < ApplicationController	
	require 'pirate_bay/base.rb'
	require 'imdb.rb'
	before_action :authenticate_user!
	before_action :set_current_page

	def index
		@user = current_user.id
		term = params[:term]
		if term.nil?
			# @current_page = '1'
			begin
				puts 'current_page : ' + @current_page

				@minimum_rating = params[:minimum_rating].nil? ? '8' : params[:minimum_rating]
				@sort_by = params[:sort_by].nil? ? 'title' : params[:sort_by]
				puts 'params minimum_rating  : ' + @minimum_rating
				puts 'params sort_by  : ' + @sort_by
				puts 'SORT BY : ' + @sort_by
				with_images = 'true'
				case @sort_by
					when 'date_added_lastest'
						toto = 'date_added'
						order_by = 'desc'
					when 'date_added_oldest'
						toto = 'date_added'
						order_by = 'asc'
					when 'year_lastest'
						toto = 'year'
						order_by = 'desc'
					when 'year_oldest'
						toto = 'year'
						order_by = 'asc'
					when 'rating'
						toto = 'rating'
						order_by = 'desc'
					when 'title'
						toto = 'title'
						order_by = 'asc'
					when 'seeds'
						toto = 'seeds'
						order_by = 'desc'
					when 'peers'
						toto = 'peers'
						order_by = 'desc'
					else
						toto = 'seeds'
				end
				order_by = order_by.nil? ? 'asc' : order_by
				limit = '50'
				response = HTTParty.get('https://yts.ag/api/v2/list_movies.json?page='+@current_page+'&minimum_rating='+@minimum_rating+'&sort_by='+toto+'&with_images='+with_images+'&order_by='+order_by+'&limit='+limit+'&quality:1080p')
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
				@movies.each do |getimage|
					response = HTTParty.get(getimage['medium_cover_image'])
					if response.code != 200
						getimage['medium_cover_image'] = view_context.image_path('notFound.png')
					end
					if View.find_by(user_id: current_user.id, movie: Movie.find_by(imdb: getimage['imdb_code']))
						getimage['view'] = true
					end
				end
				puts 'number of pages : ' + total_pages.to_s
				puts 'minimum_rating : ' + @minimum_rating
				puts 'sort_by : ' + @sort_by
				puts 'sort_by (toto): ' + toto
				puts 'order_by : ' + order_by
				# puts response

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
				@movies = @result['data']['movies']
				@total_pages = 1
				@movies.each do |getimage|
					response = HTTParty.get(getimage['medium_cover_image'])
					if response.code != 200
						getimage['medium_cover_image'] = view_context.image_path('notFound.png')
					end
					if View.find_by(user_id: current_user.id, movie: Movie.find_by(imdb: getimage['imdb_code']))
						getimage['view'] = true
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
						if View.find_by(user_id: current_user.id, movie: Movie.find_by(imdb: torrent['imdb']))
							torrent['view'] = true
						end
						torrent['title'] = i.title
						torrent['genres'] = i.genres
						torrent['rating'] = i.rating
						torrent['year'] = i.year
						torrent['description_full'] = i.plot_summary
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
		if Movie.find_by(imdb: params[:imdb])
			redirect_to movie_path(Movie.find_by(imdb: params[:imdb]).id)
		else
			if params[:torrent]
				torrent =  HTTParty.get(params[:torrent])
				torrent = BEncode.load(torrent)
				info_hash = torrent["info"].bencode
				info_sha1 = OpenSSL::Digest::SHA1.digest(info_hash)
				torrent = Base32.encode(info_sha1)
				torrent = "magnet:?xt=urn:btih:" + torrent
			else
				torrent = params[:magnet_link]
			end
			movie = Movie.create(imdb: params[:imdb], description: 'Pirate_bay recherche')
			Dir.mkdir "#{Rails.root}/public/videos/#{movie.id}"
			begin
				response = HTTParty.get("http://localhost:3001/download?magnet=#{torrent}&id=#{movie.id}")
				if JSON.parse(response.body)['ok']
				    movie.update(path: JSON.parse(response.body)['path'])
				    redirect_to movie_path(id: movie.id)
				else
					redirect_to root_path
				end
			rescue
				movie.delete
				FileUtils.remove_dir("#{Rails.root}/public/videos/#{movie.id}", true)
				redirect_to root_path
			end
		end
	end

	def show
		@video = Movie.find(params[:id])
		if !View.find_by(movie: @video, user: current_user)
			View.create(movie: @video, user: current_user)
		end
		i = Imdb::Movie.new(@video.imdb[2..-1])
		@torrent = {}
		@torrent['title'] = i.title
		@torrent['genres'] = i.genres
		@torrent['rating'] = i.rating
		@torrent['year'] = i.year
		@torrent['description_full'] = i.plot_summary
		@torrent['medium_cover_image'] = i.poster
		@torrent['cast_members'] = i.cast_members
		@torrent['production'] = i.director
		@torrent['writers'] = i.writers
		@torrent['time'] = i.length.to_s + ' minutes'
	    if @video
	      if @video.translates.empty?
	        path = @video.path[0..-1]
	        begin
		        file = Subdb::Video.new("public/" + path)
		        file_in_folder = path.split('/')[-1].split('.')[0]
		        trads = file.search
		        if trads
		          trads = trads.split(',')
		          trads.each do |trad|
		            text = file.download([trad])
		            File.open(File.join("public/videos/#{@video.id}/", file_in_folder + '-' + trad + '.srt'), 'w+') do |f|
		              f.write(text.force_encoding("UTF-8"))
		              Translate.create(path: file_in_folder + '-' + trad + '.srt', label: trad, movie: @video)
		            end
		          end
		        end
		    rescue
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
		# @total_pages = (@movies_count.to_f / @limit.to_f).ceil
		@total_pages = (@movies_count / @limit) + ((@movies_count % @limit) ? 1 : 0)

	end
end
