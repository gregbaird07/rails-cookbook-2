class CreateReviews < ActiveRecord::Migration[8.0]
  def change
    create_table :reviews do |t|
      t.references :recipe, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :rating
      t.text :comment

      t.timestamps
    end
    
    add_index :reviews, [:recipe_id, :user_id], unique: true
  end
end
