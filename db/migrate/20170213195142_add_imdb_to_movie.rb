class AddImdbToMovie < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :imdb, :string
  end
end
