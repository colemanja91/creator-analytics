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
  * Refresh videos and users for game
  * Add docs
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

## Running

### Twitch user record refreshes

Twitch user data isn't likely to change super often, so to avoid making a ton of unnecessary API calls I have the refresh logic limited to only call the Twitch GraphQL API either when a new `TwitchUser` record is created OR if it has been more than one day since the existing record was last updated.

If changing logic within the app, or some other circumstance that requires fresh calls, you can force a refresh by setting the env var `TWITCH_FORCE_USER_REFRESH=true`. Just be sure to either remove this env var or set it to `false` when done!
