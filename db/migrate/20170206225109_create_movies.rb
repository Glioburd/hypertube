class CreateMovies < ActiveRecord::Migration[5.0]
  def change
    create_table :movies do |t|
      t.string :title
      t.string :description
      t.boolean :stream, default: 0
      t.string :form
      t.string :path

      t.timestamps
    end
  end
end