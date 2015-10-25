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

## Handles

- `GET /`
returns the current API version and Github homepage

- `GET /api/v1/weekrank`
returns JSON of most popular weekly feeds info: *title*, *link*

- `GET /api/v1/dayrank`
returns JSON of most popular daily feeds info: *title*, *link*

- `GET /api/v1/feed?cat=[cat]&page=[page_no]`
returns JSON of feeds info under a specific category and page number: *title*, *author*, *date*, *content*, *tags*, *imgs*. Available categories include: `internet`, `tech`, `marketing`, `startup`, `people`, and `skill`.

	- E.g. 
		- `http://localhost:9292/api/v1/feed?cat=marketing`
		- `http://localhost:9292/api/v1/feed?cat=marketing&page=2`
	- Note that if the request parameters are invalid for crawling data, the service will return error message to notify users and suggest a normal use of queries.

	```
	[Bad request] please check the category and the page no is rational


	Page no   : should be a natural number, a.k.a. POSITIVE INTEGER, and cannot be too large.
	Categories:
			"internet", for searching "網路"
			"tech", for searching "科技"
			"marketing", for searching "行銷"
			"startup", for searching "創業"
			"people", for searching "人物"
			"skill", for searching "技能"
	```

(POST to be added.)
