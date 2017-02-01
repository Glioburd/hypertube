class AddImageOauthUrlToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :imageOauthUrl, :text
  end
end
