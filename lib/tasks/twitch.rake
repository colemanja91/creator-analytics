namespace :twitch do
  desc "Refreshes video and user (streamer) data for all current twitch games"
  task refresh_videos_for_all_games: :environment do
    game_ids = TwitchGame.all.pluck(:id)
    TwitchVideoUpdateService.new.fetch_and_update_videos_for_games!(game_ids: game_ids, language: "en")
  end
end
