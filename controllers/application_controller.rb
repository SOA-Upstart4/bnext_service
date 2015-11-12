$KCODE = 'u' if RUBY_VERSION < '1.9'

require 'sinatra/base'
require 'sinatra/flash'
require 'httparty'
require 'hirb'
require 'slim'

##
# Simple web service to crawl Bnext webpages
class ApplicationController < Sinatra::Base
  helpers BNextHelpers, TrendHelpers

  ROOT_MSG = 'This is version 0.0.1. See documentation at its ' \
      '<a href="https://github.com/SOA-Upstart4/bnext_service">' \
      'Github repo</a>'

  configure :production, :development do
    enable :logging
  end

  configure do
    Hirb.enable
  end

  get_root = lambda do
    ROOT_MSG
  end

  get_feed_ranktype = lambda do
    content_type :json, 'charset' => 'utf-8'
    cat = 'tech'
    page_no = 1

    cat = params['cat'] if params.has_key? 'cat'
    page_no = params['page'] if params.has_key? 'page'
    get_ranks(params[:ranktype], cat, page_no).to_json
  end

  post_recent = lambda do
    content_type :json, 'charset' => 'utf-8'
    begin
      req = JSON.parse(request.body.read)
      logger.info req
    rescue
      halt 400
    end

    trend = Trend.new(
      description: req['description'],
      categories: req['categories'].to_json)

    if trend.save
      status 201
      redirect "api/v1/trend/#{trend.id}", 303
    else
      halt 500, 'Error saving trend request to the database'
    end
  end

  get_trend = lambda do
    content_type :json, 'charset' => 'utf-8'
    begin
      trend = Trend.find(params[:id])
      description = trend.description
      categories = JSON.parse(trend.categories)
      logger.info({ id: trend.id, description: description }.to_json)
    rescue
      halt 400
    end

    begin
      newest_feeds(categories).to_json
    rescue
      halt 500, 'Lookup of BNext failed'
    end
  end

  # Web API Routes
  get '/', &get_root
  get '/api/v1/:ranktype', &get_feed_ranktype
  get '/api/v1/trend/:id', &get_trend

  post '/api/v1/recent', &post_recent
end
