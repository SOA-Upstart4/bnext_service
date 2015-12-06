# BnextRobot Webservice
[ ![Codeship Status for SOA-Upstart4/bnext_service](https://codeship.io/projects/98343a30-628b-0133-e9cf-1af77e49650b/status?branch=master)](https://codeship.io/projects/112642)


## Overview 
A simple version of web service that scrapes [BNext](http://www.bnext.com.tw/) data using the [bnext_robot](https://rubygems.org/gems/bnext_robot) gem.

## Repository structure
```
├── Gemfile
├── Gemfile.lock
├── LICENSE
├── Procfile
├── README.md
├── Rakefile
├── config
│   ├── database.yml
│   └── environments.rb
├── config.ru
├── controllers
│   └── application_controller.rb
├── db
│   ├── dev.db
│   ├── migrate
│   │   └── 20151107105747_create_trends.rb
│   ├── schema.rb
│   └── test.db
├── helpers
│   ├── bnext_helper.rb
│   └── trend_helper.rb
├── models
│   ├── bnext_feeds.rb
│   └── trend.rb
├── public
│   ├── fonts
│   │   ├── FontAwesome.otf
│   │   ├── fontawesome-social-webfont.eot
│   │   ├── fontawesome-social-webfont.svg
│   │   ├── fontawesome-social-webfont.ttf
│   │   ├── fontawesome-social-webfont.woff
│   │   ├── fontawesome-webfont.eot
│   │   ├── fontawesome-webfont.svg
│   │   ├── fontawesome-webfont.ttf
│   │   └── fontawesome-webfont.woff
│   ├── header.jpg
│   └── style.css
├── spec
│   ├── app_spec.rb
│   ├── bnext_spec.rb
│   ├── fixtures
│   │   └── vcr_cassettes
│   │       ├── day_rank.yml
│   │       ├── default_feed.yml
│   │       ├── internet_page_4.yml
│   │       ├── post_random.yml
│   │       ├── post_recent.yml
│   │       ├── post_trend.yml
│   │       ├── week_rank.yml
│   │       └── wrong_ranktype.yml
│   ├── spec_answers.rb
│   ├── spec_helper.rb
│   └── trend_spec.rb
└── views
    ├── feed.slim
    ├── footer.slim
    ├── home.slim
    ├── layout.slim
    └── nav.slim
```

## Quick Start

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

- `POST /api/v1/trend`
	- takes JSON: array of 'categories'
	- returns: array of categories and the newest feed in that category
		- Command line connetction example:
		```
		curl -v -H "Accept: application/json" -H "Content-type: application/json" \
		-X POST -d "{\"categories\":[\"tech\",\"marketing\"]}" \
		http://localhost:9292/api/v1/trend
		```


## Project Architecture

### Overview

<table>
	<tr>
		<td><b>FOLDER</b></td>
		<td><b>FILE</b></td>
		<td><b>DESCRIPTION</b></td>
	</tr>
	
	<!-- Controllers -->
	<tr>
		<td rowspan="1"><a href="#controllers">/controllers/</a></td>
		<td>application_controller.rb</td>
		<td>main control of the app</td>
	</tr>
	
	<!-- Helpers -->
	<tr>
		<td rowspan="2"><a href="#helpers">/helpers/</a></td>
		<td>bnext_helper.rb</td>
		<td>functions related to "Business Next"</td>
	</tr>
	<tr>
		<td>trend_help.rb</td>
		<td>functions related to keywords trend extraction</td>
	</tr>
	
	<!-- Models -->
	<tr>
		<td rowspan="2"><a href="#models">/models/</a></td>
		<td>bnext_feeds.rb</td>
		<td>Processing the data retrieving from BNextRobot into a format the app accepts</td>
	</tr>
	<tr>
		<td>trend.rb</td>
		<td>Reducing the content retrieving from BNextRobot into TREND information</td>
	</tr>
	
</table>

<h1 id="controllers" />
### Controllers

- application_controller.rb (ApplicationController)

	| API ROUTE | TYPE | METHOD | PARAMS | DESCRIPTION
	|:----:|:----:|:----:|:----:|:----
	| `/api/v1` | API | `GET` | N/A | Root directory
	| `/api/v1/dayrank` | API | `GET` | N/A | Getting daily hot feeds
	| `/api/v1/weekrank` | API | `GET` | N/A | Getting weekly hot feeds
	| `/api/v1/feed` | API | `GET` | `cat={CATEGORY}&page={PAGENO}` | Getting feeds under a specific category at specific page number
	| `/api/v1/trend/{ID}` | API | `GET` | N/A | Finding trend information with specific ID
	| `/api/v1/trend` | API | `POST` | `{ description: "{DESC}", categories: ["{CAT1}", "{CAT2}"] }` | TBD
	| `/api/v1/trend/{ID}` | API | `DELETE` | N/A | Deleting trend information with specific ID
	| `/api/v1/article` | API | `POST` | `{ body: FEED.to_json }` | Posting article to the database
	| `/api/v1/article` | API | `GET` | `viewid=` | Getting article meta data in json format
	| `/api/v1/article/filter` | API | `GET` | `tags=&author=&title=` | Retrieving articles that match the given conditions
	| `/` | GUI | `GET` | N/A |
	| `/feed/` | GUI | `GET` | N/A | 
	
<h1 id="helpers" />
### Helpers

- bnext_helper.rb

	| MODULE | FIELD | TYPE | ACCESS | PARAMS | DESCRIPTION
	|:----:|:----:|:----:|:----:|:----:|:----
	| `BNextHelpers` | `get_rank` | func returns `RankList` | public | `type: category: page: ` | retrieve `Feed`'s

- trend_helper.rb
	
	| MODULE | FIELD | TYPE | ACCESS | PARAMS | DESCRIPTION
	|:----:|:----:|:----:|:----:|:----:|:----
	| `TrendHelpers` | `get_popular_words` | func returns `Hash` | public | `max_num: cat: ` | get top `max_num` words that are puplar used so far with specific category

<h1 id="models" />
### Models

- bnext_feed.rb

	| CLASS | FIELD | TYPE | ACCESS | PARAMS | DESCRIPTION
	|:----:|:----:|:----:|:----:|:----:|:----
	| `RankFeeds` | `fetch` | func returns `RankList` | static public | `type: category: page: ` | returns an array of `Feed` that is JSON-parsable with specific configuration
	| `RankFeeds` | `type` | var | read | N/A | `dayrank`<br/>\|`weekrank` <br/>\|`feed`
	| `RankFeeds` | `category` | var | read | N/A | see Quick Start
	| `RankFeeds` | `page` | var | read | N/A | see Quick Start
	| `RankList` | `to_json` | func returns string | public | N/A | parse to JSON string

- trend.rb

	| CLASS | FIELD | TYPE | ACCESS | PARAMS | DESCRIPTION
	|:----:|:----:|:----:|:----:|:----:|:----
	| `Trend` | `keywords` | var | read | N/A | a Hash that stores word/int as key-value pairs
	| `TrendFactory` | `shared_instance` | var | static public | N/A | singleton handle
	| `TrendFactory` | `get_corpora` | func returns array | public | N/A | link to the db and get the latest statistical texts model
	| `TrendFactory` | `process` | func returns `Trend` | public | `feed: ` | analyze the content to extract possible keywords that match the statistical model
