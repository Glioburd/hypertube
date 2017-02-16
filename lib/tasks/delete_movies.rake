desc 'delete movie expires 1 month'
task delete_movies: :environment do
  Movie.all.each do |movie|
  	if !movie.views.find_by(['created_at > ?', 30.days.ago])
      FileUtils.remove_dir("#{Rails.root}/public/videos/#{movie.id}", true)
      movie.delete
    end
  end
end