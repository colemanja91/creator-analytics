class TwitchVideo < ApplicationRecord
  belongs_to :twitch_game
  belongs_to :twitch_user
end
