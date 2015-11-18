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
  enable :sessions
  register Sinatra::Flash
  use Rack::MethodOverride

  set :views, File.expand_path('../../views', __FILE__)
  set :public_folder, File.expand_path('../../public', __FILE__)

  configure do
    Hirb.enable
    set :session_secret, 'something'
    set :api_ver, 'api/v1'
  end

  configure :development, :test do
    set :api_server, 'http://localhost:9292'
  end

  configure :production do
    set :api_server, 'https://trendcrawl.herokuapp.com/'
  end

  configure :production, :development do
    enable :logging
  end

  helpers do
    def current_page?(path = ' ')
      path_info = request.path_info
      path_info += ' ' if path_info == '/'
      request_path = path_info.split '/'
      request_path[1] == path
    end
  end

  ROOT_MSG = 'This is version 0.0.1. See documentation at its ' \
      '<a href="https://github.com/SOA-Upstart4/bnext_service">' \
      'Github repo</a>'

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

  post_trend = lambda do
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
      results = newest_feeds(categories).to_json
    rescue
      halt 500, 'Lookup of BNext failed'
    end

    #{ id: trend.id, description: description,
    #  categories: categories, newest: results }.to_json
  end

  delete_trend = lambda do
    trend = Trend.destroy(params[:id])
    status(trend > 0 ? 200 : 404)
  end

  # Web API Routes
  get '/api/v1/?', &get_root
  get '/api/v1/:ranktype/?', &get_feed_ranktype
  get '/api/v1/trend/:id/?', &get_trend
  post '/api/v1/trend/?', &post_trend
  delete '/api/v1/trend/:id/?', &delete_trend

# Web app views
  app_get_root = lambda do
    slim :home
  end

  app_get_feed = lambda do
    @ranktype = params[:ranktype]
    # @cat = params['cat'] if params.has_key? 'cat'
    # @page_no = params['page'] if params.has_key? 'page'
    if @ranktype
      redirect "/feed/#{@ranktype}"
      # To be included: redirect to get feeds in specific cat/page
      return nil
    end

    slim :feed
  end

  app_get_feed_ranktype = lambda do
    @ranktype = params[:ranktype]
    @cat = params['cat'] if params.has_key? 'cat'
    @page_no = params['page'] if params.has_key? 'page'
    @rank = get_ranks(@ranktype, @cat, @page_no)

    if @ranktype && @rank.nil?
      flash[:notice] = 'no feed found' if @rank.nil?
      redirect '/feed'
      return nil
    end

    slim :feed
  end

  app_get_trend = lambda do
    id = params[:id];
    if id
      begin
        trend = Trend.find(params[:id])
        description = trend.description
        categories = JSON.parse(trend.categories)
        logger.info({ id: trend.id, description: description }.to_json)
      rescue
        halt 400
      end

      begin
        results = newest_feeds(categories).to_json
      rescue
        halt 500, 'Lookup of BNext failed'
      end
    end

    slim :trend
  end

  # To be added: app_get_trend, app_post_trend,app_get_trend_id, app_delete_trend_id

  # Web App Views Routes
  get '/?', &app_get_root
  get '/feed/?', &app_get_feed
  get '/feed/:ranktype/?', &app_get_feed_ranktype
  get '/trend/?', &app_get_trend
  # To be added: get '/trend', post '/trend', get '/trend/:id', delete '/trend/:id'
end
