class CreateRatings < ActiveRecord::Migration[8.0]
  def change
    create_table :ratings do |rating|
      rating.references :post, null: false, foreign_key: true
      rating.references :user, null: false, foreign_key: true
      rating.integer :value, null: false

      rating.timestamps
    end
  end
end
