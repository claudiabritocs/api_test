class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |user|
      user.string :login

      user.timestamps
    end
    add_index :users, :login, unique: true
  end
end
