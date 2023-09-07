namespace :prompt do
  desc "Create a few-shot prompt ranked by view count for a category"
  task :by_views, [:category_id, :min_view_count, :max_view_count, :target_game_name] => :environment do |_t, args|
    game_ids = TwitchGame.where(category_id: args.category_id.to_i)
    min_view_count = min_view_count.to_i
    max_view_count = max_view_count.to_i
    target_game_name = args.target_game_name

    generator = Generator::TwitchVideoTitleFewShotPrompt.new(game_ids: game_ids)
    prompt = generator.generate_by_view_count(min_view_count, max_view_count, target_game_name)
    puts prompt
  end
end
