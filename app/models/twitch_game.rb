class TwitchGame < ApplicationRecord
  has_many :twitch_videos
  belongs_to :category, optional: true
end
