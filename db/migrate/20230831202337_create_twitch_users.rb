class CreateTwitchUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :twitch_users do |t|
      t.string :login, null: true
      t.integer :follower_count, default: 0, null: true
      t.boolean :is_partner, default: false, null: true
      t.boolean :is_affiliate, default: false, null: true
      t.timestamps
    end

    add_foreign_key :twitch_videos, :twitch_users, column: :twitch_user_id
  end
end
