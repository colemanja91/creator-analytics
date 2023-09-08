namespace :prompt do
  desc "Create a few-shot prompt ranked by view count for a category"
  task :by_ratio, [:category_id, :target_game_name] => :environment do |_t, args|
    category_id = args.category_id.to_i
    target_game_name = args.target_game_name

    generator = Generator::TwitchVideoTitleFewShotPrompt.new(category_id: category_id)
    prompt = generator.generate_prompt(target_game_name)
    puts prompt
  end
end
