module Segments
  MAX_AGE_IN_DAYS = 30

  class TwitchVideoByViewerToFollowerRatio
    def initialize(category_id:)
      @category = Category.find(category_id)
    end

    attr_reader :category

    def videos
      query = "*, (twitch_videos.view_count / twitch_user.follower_count) AS view_to_follower_ratio"

      twitch_videos.select(query).order(view_to_follower_ratio: :desc)
    end

    private

    def user_segment
      Segments::TwitchUserPreAffiliate.new.users
    end

    def twitch_videos
      @twitch_videos ||= TwitchVideo
        .includes(:twitch_user)
        .where(twitch_user: {id: user_segment.pluck(:id)})
        .where(twitch_game_id: category.twitch_games.pluck(:id))
        .where("twitch_videos.created_at > ?", MAX_AGE_IN_DAYS.days.ago)
        .where("twitch_videos.view_count > ?", 0)
    end
  end
end
