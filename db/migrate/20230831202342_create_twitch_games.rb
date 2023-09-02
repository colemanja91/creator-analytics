class CreateTwitchGames < ActiveRecord::Migration[7.0]
  def change
    create_table :twitch_games do |t|
      t.string :name
      t.timestamps
    end

    add_column :twitch_videos, :twitch_game_id, :bigint

    add_foreign_key :twitch_videos, :twitch_games, column: :twitch_game_id
  end
end
