class CreateTwitchVideos < ActiveRecord::Migration[7.0]
  def change
    create_table :twitch_videos do |t|
      t.bigint :stream_id, null: true
      t.string :language
      t.string :title
      t.integer :view_count
      t.string :video_type
      t.bigint :twitch_user_id
      t.string :duration
      t.timestamps
    end
  end
end
