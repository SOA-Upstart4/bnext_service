$KCODE = 'u' if RUBY_VERSION < '1.9'

require 'sinatra/base'
require_relative './model/bnext_feeds'
require_relative 'bnext_helper'

##
# Simple web service to crawl Bnext webpages
class BNextcadetApp < Sinatra::Base
  helpers BNextHelpers

  ROOT_MSG = 'This is version 0.0.1. See documentation at its ' \
      '<a href="https://github.com/SOA-Upstart4/bnext_service">' \
      'Github repo</a>'

  configure :production, :development do
    enable :logging
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
    content_type :json
    begin
      req = JSON.parse(request.body.read)
      logger.info req
    rescue
      halt 400
    end

    newest_feeds(req['categories']).to_json
  end

  # Web API Routes
  get '/', &get_root
  get '/api/v1/:ranktype', &get_feed_ranktype
  post '/api/v1/recent', &post_recent
end
