class AddQualityToMovie < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :quality, :string
  end
end
