module Generator
  class TwitchVideoTitleFewShotPrompt
    def initialize(game_ids:)
      @game_ids = game_ids
    end

    attr_reader :min_follow_count, :max_follow_count, :min_view_count, :max_view_count, :game_ids

    def generate_by_follow_count(min_follow_count, max_follow_count, target_game_name, key_concepts, shot_size = 5)
      @min_follow_count = min_follow_count
      @max_follow_count = max_follow_count

      segment = twitch_video_segment_by_user_follows
      prompt_2(segment, shot_size, target_game_name, key_concepts)
    end

    def generate_by_view_count(min_view_count, max_view_count, target_game_name, shot_size = 5)
      @min_view_count = min_view_count
      @max_view_count = max_view_count

      segment = twitch_video_segment_by_views
      prompt_2(segment, target_game_name, shot_size)
    end

    private

    def prompt_2(video_segment, target_game_name, shot_size)
      video_subset_best = video_segment.first(shot_size)
      video_subset_worst = video_segment.last(shot_size)

      prompt = "This is a stream title generator.\n\n"

      0.step(shot_size - 1, 1) do |i|
        good_video = video_subset_best[i]
        bad_video = video_subset_worst[i]
        prompt += "Good title (game: '#{good_video.twitch_game.name}'): '#{good_video.title}'\n\n"
        prompt += "Bad title (game: '#{good_video.twitch_game.name}'): '#{bad_video.title}'\n\n"
      end
      prompt += "Good title (game: '#{target_game_name}'): "
      prompt
    end

    def prompt(video_segment, shot_size, target_game_name, key_concepts)
      video_subset_best = video_segment.first(shot_size)
      video_subset_worst = video_segment.last(shot_size)
      prompt = "The following are recent twitch stream titles in the format "
      prompt += "\"<< STREAM TITLE >> {{ VIEW COUNT }}\", where \"VIEW COUNT\" is the current measure of success (higher values are good, lower values are bad):\n\n"
      video_subset_best.each do |video|
        prompt += format_video_for_prompt(video)
      end
      video_subset_worst.each do |video|
        prompt += format_video_for_prompt(video)
      end

      prompt += "\n\n Using these as reference, create a new stream title for the game #{target_game_name} "
      prompt += "which optionally references the following concepts: #{key_concepts}\n\n"
      prompt += "Output should be returned in the format << GENERATED STREAM TITLE >>"

      puts prompt
    end

    def format_video_for_prompt(video)
      "<< #{video.title} >> {{ #{video.view_count} }}\n"
    end

    def twitch_video_segment_by_views
      @twitch_video_segment ||= TwitchVideo
        .where(twitch_game_id: game_ids)
        .where("view_count >= ?", min_view_count)
        .where("view_count <= ?", max_view_count)
        .where("created_at > ?", 30.days.ago)
        .order(view_count: :desc)
    end

    def twitch_video_segment_by_user_follows
      @twitch_video_segment ||= TwitchVideo
        .where(twitch_user_id: twitch_user_segment_ids_by_follow_count)
        .where(twitch_game_id: game_ids)
        .where("created_at > ?", 30.days.ago)
        .order(view_count: :desc)
    end

    def twitch_user_segment_ids_by_follow_count
      @twitch_user_segment_ids ||= TwitchUser
        .where("follower_count >= ?", min_follow_count)
        .where("follower_count <= ?", max_follow_count)
        .where("is_partner = ?", false)
        .where("is_affiliate = ?", false)
        .pluck(:id)
    end
  end
end
