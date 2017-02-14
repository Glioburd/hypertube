class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.text :content
      t.integer :id_user
      t.integer :id_movie

      t.timestamps
    end
  end
end
