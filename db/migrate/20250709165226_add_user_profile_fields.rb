class AddUserProfileFields < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :username, :string
    add_column :users, :bio, :text
    add_column :users, :avatar_url, :string
    
    add_index :users, :username, unique: true
  end
end
