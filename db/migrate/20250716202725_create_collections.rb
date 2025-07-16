class CreateCollections < ActiveRecord::Migration[8.0]
  def change
    create_table :collections do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.text :description
      t.boolean :is_public, default: false, null: false

      t.timestamps
    end
    
    add_index :collections, [:user_id, :name], unique: true
    add_index :collections, :is_public
  end
end
