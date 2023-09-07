class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false, unique: true
      t.timestamps
    end

    add_column :twitch_games, :category_id, :bigint

    add_foreign_key :twitch_games, :categories, column: :category_id
  end
end
