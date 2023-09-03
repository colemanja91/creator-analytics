class TwitchVideoUpdateService
  def fetch_and_update_videos_for_games!(game_ids:, language:)
    game_ids.each do |game_id|
      fetch_and_update_videos_for_game!(game_id: game_id, language: language)
    end
  end

  def fetch_and_update_videos_for_game!(game_id:, language:)
    game = TwitchGame.find(game_id)
    videos = twitch_service.videos_for_game(game_id: game_id, period: "month", language: language)

    user_ids = videos.map { |v| v.user_id }

    update_users(user_ids: user_ids)
    videos.each do |video|
      twitch_video = game.twitch_videos.find_or_create_by(id: video.id)
      twitch_video.update!(
        language: video.language,
        title: video.title,
        view_count: video.view_count,
        video_type: video.type,
        twitch_user_id: video.user_id,
        duration: video.duration,
        created_at: video.created_at
      )
    end
  end

  private

  def update_users(user_ids:)
    user_ids.each do |user_id|
      user = TwitchUser.find_or_create_by(id: user_id)

      if user.updated_at < 1.day.ago || user.new_record? || Setting.twitch(:force_user_refresh)
        user_result = twitch_graphql_service.get_user(user_id)
        user.update!(
          login: user_result["login"],
          follower_count: user_result["followers"]["totalCount"],
          is_partner: user_result["roles"]["isPartner"],
          is_affiliate: user_result["roles"]["isAffiliate"],
          created_at: user_result["createdAt"]
        )
        rate_limit
      end
    end
  end

  def rate_limit
    return if Rails.env.test?
    sleep(1)
  end

  def twitch_graphql_service
    @twitch_graphql_service ||= TwitchGraphqlService.new
  end

  def twitch_service
    @twitch_service ||= TwitchService.new
  end
end
