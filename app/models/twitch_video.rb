class TwitchVideo < ApplicationRecord
  belongs_to :twitch_game, optional: true
  belongs_to :twitch_user
end
