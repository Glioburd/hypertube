class CreateTranslates < ActiveRecord::Migration[5.0]
  def change
    create_table :translates do |t|
      t.references :movie, foreign_key: true
      t.string :path
      t.string :label

      t.timestamps
    end
  end
end
