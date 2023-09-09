# README

This app is an exploration in helping creators better analyze their environments and make smarter decisions to reach more people.

Only intended to be run locally - you will need to supply your own API credentials for it to work (I will add steps detailing how to do this).

## Appreciation

This would have been a lot more difficult to put together if not for the amazing gem created by @mauricew https://github.com/mauricew/ruby-twitch-api - thank you!

## TODO

* Add setup details
  * how to install each service, running setup script, etc
* Add rake tasks
  * New game
* Add `TwitchVideoExperiment` model
* Add `TwitchVideoExperimentInput` model
* Add `TwitchVideoExperimentGame` model
  * These will be similar games that might be applicable and help provide a larger data set (after filtering by follower count)
  * i.e. you might want an experiment for "Pokemon X/Y", but it's very likely that other Pokemon games would have applicable data
* Add video ranking generator
  * Filter to target audience size by follow count (i.e., if you currently have 5 followers, set range to a min of 10 and a max of 25)
  * Rank video titles by view count descending and assign a normalized score of 0 - 100
  * Store ranks as `TwitchVideoExperimentInput` records
* Add link to OpenAI API to train and create a new prediction
* Add rake tasks to setup new experiment with similar games
* Make refresh tasks smarter (i.e. only refresh once per day)

## Setup

* Install Ruby
* Install PostgreSQL

## Twitch API Credentials

### Client ID and Client Secret

* Go to the [Twitch Developer Console](https://dev.twitch.tv/console)
* Click "Register Your Application"
* Fill out the details
  * "Name" must be globally-unique for Twitch - I used a throwaway name appended to my username
  * "OAuth Redirect URLs": `http://localhost`
  * "Category": Application Integration
  * "I'm not a robot": probably?
* Copy the "Client ID" value and set it as an environment variable: `TWITCH_CLIENT_ID`
* Click "New Secret" and set it as an environment variable: `TWITCH_CLIENT_SECRET`

### Client GraphQL Secret

A few API requests go to Twitch's undocumented GraphQL API. Regular Application Client ID values won't work with these requests.

* Go to [Twitch](https://twitch.tv)
* Open your browser's developer console and go to the network tab
* Filter requests by the string "gql"
* In the request headers, look for a header called "Client-ID"
* Copy that value and set it as an environment variable: `TWITCH_GRAPHQL_CLIENT_ID`

## Modeling

### Categories

Twitch does not currently have a high-level concept of a "category" - meaning individual games in a franchise must be browsed separately. An example of this is Pokemon: there are many games, but for discoverability, a lot of streamers list their stream under the latest title.

In some analytics use cases, it can be helpful to have a category to group similar data points. In this app, the `Category` model fills this role.

### Segments

For growth purposes, my hypothesis is that while it can be helpful to look at what large streamers do, it's more immediately helpful to look at streamers who are a "next step" up from your current stage. Segments help define these groups for easy/consistent reference:

* `Segments::TwitchUserPreAffiliate`:
  * Not currently partner or affiliate
  * Has more 5 - 49 followers (inclusive)
  * _Note:_ There are other criteria for becoming a Twitch affiliate, but these are the only points we can easily scrape

## Running

### Refreshing videos for games

This rake task will refresh videos for all `TwitchGame` records within the last week:

```sh
bundle exec rake twitch:refresh_videos_for_all_games
```

It will also refresh `TwitchUser` records for the associated streamers. This call goes against the Twitch GraphQL API, which is currently a little more uncertain in terms of long-term stability. Because of that, the API is only called when there's a record we do not already have, OR when it's been more than a day since the existing record was last updated. 

While doing initial DB setup or development work, it may be necessary to overwrite this, which can be done as follows:

```sh
TWITCH_FORCE_USER_REFRESH=true bundle exec rake twitch:refresh_videos_for_all_games
```

### Refreshing videos for games

This rake task will refresh videos for all `Segments::TwitchUserPreAffiliate` users (may add general support for more segments as they are created):

```sh
bundle exec rake twitch:refresh_videos_for_pre_affiliates
```

Note that Twitch does not currently return `game_id` in their "Get Videos" endpoint (likely due to videos potentially belonging to multiple games), so `TwitchGame` records are not created/updated.

## AI Prompts

**THIS IS STILL A VERY ROUGH WORK-IN-PROGRESS**, is likely to change frequently, and I may forget to update this doc in the process.

### By Viewer/Follower Ratio

**Hypothesis**: Videos with a higher viewer/follower ratio have better titles

**Caveats**:
* Video titles are not 100% representative of stream titles, as streamers may change titles partway through a stream
* Views driven by community engagement (i.e. social posts), go-live notifications for existing followers, and entertainment quality of the stream
* Follow count may change at a later time and not be fully representative of data at time of the stream

_Most_ of these caveats could be solved by storing better live data - i.e., stream starts, follows, live view count, etc. These data points are not available via Helix, but most are more accessible via webhooks. I have not implemented these yet due to only running this app locally for The Time Being. 
