require "rails_helper"

RSpec.describe TwitchVideoUpdateService do
  let(:twitch_service) { instance_double(TwitchService) }
  let(:twitch_graphql_service) { instance_double(TwitchGraphqlService) }

  before do
    allow(TwitchService).to receive(:new).and_return(twitch_service)
    allow(TwitchGraphqlService).to receive(:new).and_return(twitch_graphql_service)
  end

  describe "#fetch_and_update_videos_for_game!" do
    let(:subject) { described_class.new.fetch_and_update_videos_for_game!(game_id: game.id, language: language) }
    let(:game) { TwitchGame.create(name: "Pokemons") }
    let(:language) { "en" }

    context "no videos found" do
      before do
        allow(twitch_service).to receive(:videos_for_game).with(game_id: game.id, period: "month", language: language).and_return([])
      end

      it "does not error if no videos returned" do
        expect { subject }.not_to change { TwitchVideo.count }
      end
    end

    context "video found" do
      let(:user_id) { 12345 }

      let(:videos) do
        [
          Twitch::Video.new(id: 456, language: "en", title: "Awesome", view_count: 50, type: "archive", user_id: user_id, duration: "3m21s", created_at: "2020-11-09T19:45:52.730354Z"),
          Twitch::Video.new(id: 789, language: "en", title: "mediocre", view_count: 0, type: "highlight", user_id: user_id, duration: "5m", created_at: "2020-11-09T19:45:52.730354Z")
        ]
      end

      before do
        allow(twitch_graphql_service).to receive(:get_user).with(user_id).and_return({
          "login" => "allie_nord",
          "followers" => {
            "totalCount" => 3
          },
          "roles" => {
            "isPartner" => true,
            "isAffiliate" => true
          },
          "createdAt" => "2020-11-09T19:45:52.730354Z"
        })

        allow(twitch_service).to receive(:videos_for_game).with(game_id: game.id, period: "month", language: language).and_return(videos)
      end

      it "creates new videos" do
        expect { subject }.to change { TwitchVideo.count }.by(2)
      end

      it "creates new users" do
        expect { subject }.to change { TwitchUser.count }.by(1)
      end

      context "user already exists" do
        before do
          TwitchUser.create(id: user_id, login: "allie_nord")
        end

        it "does not create a new user" do
          expect { subject }.not_to change { TwitchUser.count }
        end
      end
    end
  end
end
