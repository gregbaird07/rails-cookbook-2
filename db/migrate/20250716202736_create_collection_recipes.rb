class CreateCollectionRecipes < ActiveRecord::Migration[8.0]
  def change
    create_table :collection_recipes do |t|
      t.references :collection, null: false, foreign_key: true
      t.references :recipe, null: false, foreign_key: true
      t.integer :position, default: 0

      t.timestamps
    end
    
    add_index :collection_recipes, [:collection_id, :recipe_id], unique: true
    add_index :collection_recipes, [:collection_id, :position]
  end
end
