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

* Go to the [Twitch Developer Console](https://dev.twitch.tv/console)
* Click "Register Your Application"
* Fill out the details
  * "Name" must be globally-unique for Twitch - I used a throwaway name appended to my username
  * "OAuth Redirect URLs": `http://localhost`
  * "Category": Application Integration
  * "I'm not a robot": probably?
* Copy the "Client ID" value and set it as an environment variable: `TWITCH_CLIENT_ID`
* Click "New Secret" and set it as an environment variable: `TWITCH_CLIENT_SECRET`
