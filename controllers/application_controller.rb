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
  use Rack::Session::Pool
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
    set :api_server, 'https://trendcrawl.herokuapp.com'
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
      feeds_dict = newest_feeds(categories)
      results = Hash.new
      feeds_dict.map { |k, v| results[k] = v }
      results = results.to_json
    rescue
      halt 500, 'Lookup of BNext failed'
    end

    #{ id: trend.id, description: description,
    #  categories: categories, newest: results }.to_json
  end

  delete_trend = lambda do
    trend = Trend.delete(params[:id])
    status(trend 0 ? 200 : 404)
  end

  post_article = lambda do
    content_type :json, 'charset' => 'utf-8'
    begin
      req = JSON.parse(request.body.read)
      logger.info req
    rescue
      halt 400
    end

    article = Article.new(
        title: req['title'],
        author: req['author'],
        date: req['date'],
        tags: req['tags'].to_json,
        link: req['link']
      )

    if article.save
      status 201
    else
      halt 500, 'Error saving article request to the database'
    end
  end

  get_article_id = lambda do
    content_type :json, 'charset' => 'utf-8'
    begin
      article = Article.find(params[:id])
      resp = Hash.new
      resp['title'] = article.title
      resp['author'] = article.author
      resp['date'] = article.date
      resp['tags'] = JSON.parse(article.tags)
      resp['link'] = article.link
    rescue
      halt 500, 'Lookup of Articles failed'
    end
  end

  delete_article = lambda do
    article_cnt = Article.delete(params[:id])
    status(article_cnt > 0 ? 200 : 404)
  end

  # Web API Routes
  get '/api/v1/?', &get_root
  get '/api/v1/:ranktype/?', &get_feed_ranktype
  get '/api/v1/trend/:id/?', &get_trend
  post '/api/v1/trend/?', &post_trend

  delete '/api/v1/trend/:id/?', &delete_trend
  post '/api/v1/article/?', &post_article
  get '/api/v1/article/:id/?', &get_article_id
  delete '/api/v1/article/:id/?', &delete_article


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
    @action = :create
    slim :trend
  end

  app_post_trend = lambda do
    request_url = "#{settings.api_server}/#{settings.api_ver}/trend"
    categories = params[:categories]
    params_h = { categories: categories }

    options = {
      body: params_h.to_json,
      headers: { 'Content-Type' => 'application/json' }
    }

    result = HTTParty.post(request_url, options)

    if (result.code != 200)
      flash[:notice] = 'Could not process your request'
      redirect '/trend'
      return nil
    end

    id = result.request.last_uri.path.split('/').last
    session[:results] = result.to_json
    session[:action] = :create
    redirect "/trend/#{id}"
  end

  app_get_trend_id = lambda do
    if session[:action] == :create
      @results = JSON.parse(session[:results])
    else
      request_url = "#{settings.api_server}/#{settings.api_ver}/trend/#{params[:id]}"
      options =  { headers: { 'Content-Type' => 'application/json' } }
      @results = HTTParty.get(request_url, options)
      if @results.code != 200
        flash[:notice] = 'Cannot find record'
        redirect '/trend'
      end
    end

    @id = params[:id]
    @action = :update
    @categories = @results['categories']
    slim :trend
  end

  app_delete_trend_id = lambda do
    request_url = "#{settings.api_server}/#{settings.api_ver}/trend/#{params[:id]}"
    HTTParty.delete(request_url)
    flash[:notice] = 'record of trend deleted'
    redirect '/trend'
  end

  # To be added: app_get_trend, app_post_trend,app_get_trend_id, app_delete_trend_id

  # Web App Views Routes
  get '/?', &app_get_root
  get '/feed/?', &app_get_feed
  get '/feed/:ranktype/?', &app_get_feed_ranktype
  get '/trend/?', &app_get_trend
  post '/trend/?', &app_post_trend
  get '/trend/:id/?', &app_get_trend_id
  delete '/trend/:id/?', &app_delete_trend_id
  # To be added: get '/trend', post '/trend', get '/trend/:id', delete '/trend/:id'
end
