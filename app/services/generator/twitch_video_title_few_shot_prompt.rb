module Generator
  class TwitchVideoTitleFewShotPrompt
    def initialize(min_follow_count:, max_follow_count:, game_ids:)
      @min_follow_count = min_follow_count
      @max_follow_count = max_follow_count
      @game_ids = game_ids
    end

    attr_reader :min_follow_count, :max_follow_count, :game_ids

    def prompt(target_game_name, key_concepts)
      video_subset = twitch_video_segment.first(5)
      prompt = "The following are recent successful twitch stream titles in the format "
      prompt += "\"<< STREAM TITLE >> {{ VIEW COUNT }}\", where \"VIEW COUNT\" is the current measure of success:\n\n"
      video_subset.each do |video|
        prompt += format_video_for_prompt(video)
      end

      prompt += "\n\n Using these as reference, create a new stream title for the game #{target_game_name} "
      prompt += "which optionally references the following concepts: #{key_concepts}"

      puts prompt
    end

    private

    def format_video_for_prompt(video)
      "<< #{video.title} >> {{ #{video.view_count} }}\n"
    end

    def twitch_video_segment
      @twitch_video_segment ||= TwitchVideo
        .where(twitch_user_id: twitch_user_segment_ids)
        .where(twitch_game_id: game_ids)
        .where("created_at > ?", 30.days.ago)
        .order(view_count: :desc)
    end

    def twitch_user_segment_ids
      @twitch_user_segment_ids ||= TwitchUser
        .where("follower_count >= ?", min_follow_count)
        .where("follower_count <= ?", max_follow_count)
        .where("is_partner = ?", false)
        .where("is_affiliate = ?", false)
        .pluck(:id)
    end
  end
end
