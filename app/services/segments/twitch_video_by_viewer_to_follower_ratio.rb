module Segments
  MAX_AGE_IN_DAYS = 30

  class TwitchVideoByViewerToFollowerRatio
    def initialize(category_id:, max_followers:, min_followers: 5)
      @category = Category.find(category_id)
      raise StandardError.new("min_followers must be greater than 0") unless min_followers > 0
      @max_followers = max_followers
      @min_followers = min_followers
    end

    attr_reader :category, :max_followers, :min_followers

    def videos
      query = "*, (twitch_videos.view_count / twitch_user.follower_count) AS view_to_follower_ratio"

      twitch_videos.select(query).order(view_to_follower_ratio: :desc)
    end

    private

    def twitch_videos
      @twitch_vieos ||= TwitchVideo
        .includes(:twitch_user)
        .joins(:twitch_game)
        .where("twitch_user.follower_count >= ?", min_followers)
        .where("twitch_user.follower_count <= ?", max_followers)
        .where(twitch_user: {is_partner: false})
        .where(twitch_user: {is_affiliate: false})
        .where(twitch_game: {category_id: category.id})
        .where("twitch_videos.created_at > ?", MAX_AGE_IN_DAYS.days.ago)
        .where("twitch_videos.view_count > ?", 0)
    end
  end
end
