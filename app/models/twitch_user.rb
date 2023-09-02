class TwitchUser < ApplicationRecord
  has_many :twitch_videos
end
