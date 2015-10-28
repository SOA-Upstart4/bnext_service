$KCODE = 'u' if RUBY_VERSION < '1.9'

require 'sinatra/base'
require_relative './model/bnext_feeds'
require_relative 'bnext_helper'

##
# Simple web service to crawl Bnext webpages
class BNextcadetApp < Sinatra::Base
  helpers BNextHelpers

  get_root = lambda do
    'This is version 0.0.1. See documentation at its ' \
      '<a href="https://github.com/SOA-Upstart4/bnext_service">' \
      'Github repo</a>'
  end
  
  get_feed_ranktype = lambda do
    content_type :json, 'charset' => 'utf-8'
    cat = 'tech'
    page_no = 1

    cat = params['cat'] if params.has_key? 'cat'
    page_no = params['page'] if params.has_key? 'page'
    get_ranks(params[:ranktype], cat, page_no).to_json
  end
  
  # to do: POST to be added here

  # Web API Routes
  get '/', &get_root
  get '/api/v1/:ranktype', &get_feed_ranktype
  # to do: POST route to be added here
end
