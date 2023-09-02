class TwitchService
  def videos_for_game(game_id:, period:, language:)
    has_more = true
    cursor = nil
    videos_json = []
    while has_more
      videos = client.get_videos({game_id: game_id, period: period, language: language, after: cursor}.compact)
      videos.data.map { |v| videos_json << v }
      cursor = videos.pagination.fetch("cursor", nil)
      has_more = cursor.present?
      rate_limit
    end

    videos_json
  end

  def add_game_by_name(name:)
    result = client.get_games(name: name).data.first
    game = TwitchGame.find_or_create_by(id: result.id, name: result.name)
  end

  private

  def rate_limit
    return if Rails.env.test?
    sleep(1)
  end

  def tokens
    @tokens ||= TwitchOAuth2::Tokens.new(
      client: {
        client_id: Setting.twitch(:client_id),
        client_secret: Setting.twitch(:client_secret)
      },
      token_type: :application
    )
  end

  def client
    @client ||= Twitch::Client.new(tokens: tokens)
  end
end
