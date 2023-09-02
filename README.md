# README

This app is an exploration in helping creators better analyze their environments and make smarter decisions to reach more people.

## Setup

* Install Ruby
* Install PostgreSQL

## Twitch API Credentials

## Rake Tasks

Tasks will be used to refresh data, add seed data, etc, in the period before the GraphQL API is built.

### Add a new creator

A creator is the model record indicating the "user" of the app.

Arguments (ordered):

* Twitch User ID
* Language (ISO-2 code, i.e. `en`)

```sh
bundle exec rake creator:add[12345,'en']
```

### Add a new Twitch game

Creates a model record representing a Twitch game. The only argument is the Twitch Game ID.

```sh
bundle exec rake twitch:add_game[98765]
```

### Refresh videos and users for a game

Searches Twitch for videos for a specified game within the last month and adds them as DB records, along with the associated users.

```sh

```