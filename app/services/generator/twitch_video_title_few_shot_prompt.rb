module Generator
  class TwitchVideoTitleFewShotPrompt
    def initialize(category_id:)
      @category_id = category_id
    end

    attr_reader :category_id

    def generate_prompt(max_followers, target_game_name, shot_size = 5)
      segment = Segments::TwitchVideoByViewerToFollowerRatio.new(category_id: category_id, max_followers: max_followers).videos

      prompt(segment, target_game_name, shot_size)
    end

    private

    def prompt(video_segment, target_game_name, shot_size)
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
  end
end
