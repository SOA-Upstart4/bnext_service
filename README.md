# BnextRobot Webservice

## Overview
A simple version of web service that scrapes [BNext](http://www.bnext.com.tw/) data using the [bnext_robot](https://rubygems.org/gems/bnext_robot) gem.

## Repository structure
```
├── app.rb
├── config.ru
├── Gemfile
├── Gemfile.lock
├── LICENSE
├── model
│   └── bnext_feeds.rb
├── Procfile
├── Rakefile
├── README.md
└── spec
    ├── app_spec.rb
    └── spec_helper.rb
```

## Handles:

- `GET /`
returns the current API version and Github homepage

- `GET /api/v1/weekrank.json`
returns JSON of most popular weekly feeds info: *title*, *link*

- `GET /api/v1/dayrank.json`
returns JSON of most popular daily feeds info: *title*, *link*

- `GET /api/v1/feed?cat=[cat]&page=[page_no]`
returns JSON of feed info under particlar category and page number: *title*, *author*, *date*, *content*, *tags*, *imgs*. Available categories include: `internet`, `tech`, `marketing`, `startup`, `people`, and `skill`.

(POST to be added.)
