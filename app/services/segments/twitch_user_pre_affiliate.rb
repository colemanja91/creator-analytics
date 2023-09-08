module Segments
  MIN_FOLLOWERS = 5
  MAX_FOLLOWERS = 49

  class TwitchUserPreAffiliate
    def users
      @users ||= TwitchUser
        .where(is_partner: false)
        .where(is_affiliate: false)
        .where("follower_count >= ?", MIN_FOLLOWERS)
        .where("follower_count <= ?", MAX_FOLLOWERS)
    end
  end
end
