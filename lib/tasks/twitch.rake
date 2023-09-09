namespace :twitch do
  desc "Refreshes video and user (streamer) data for all current twitch games"
  task refresh_videos_for_all_games: :environment do
    game_ids = TwitchGame.all.pluck(:id)
    TwitchVideoUpdateService.new.fetch_and_update_videos_for_games!(game_ids: game_ids, language: "en", period: "week")
  end

  desc "Refresh videos for pre-affiliate streamers"
  task refresh_videos_for_pre_affiliates: :environment do
    user_ids = Segments::TwitchUserPreAffiliate.new.users.pluck(:id)
    TwitchVideoUpdateService.new.fetch_and_update_videos_for_users!(user_ids: user_ids, language: "en", period: "month")
  end
end
