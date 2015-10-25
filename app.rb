$KCODE = 'u' if RUBY_VERSION < '1.9'

require 'sinatra/base'
require_relative './model/bnext_feeds'

class BNextcadetApp < Sinatra::Base
  helpers do
    def get_ranks(ranktype, category, page)
      RankFeeds.fetch(ranktype, category, page)
    rescue
      halt 404
    end
  end

  get '/' do
    'This is version 1. Our Github homepage is : https://github.com/SOA-Upstart4/bnext_service'
  end

  get '/api/v1/:ranktype' do
    content_type :json, 'charset' => 'utf-8'
    cat = 'tech'
    page_no = 1

    cat = params['cat'] if params.has_key? 'cat'
    page_no = params['page'] if params.has_key? 'page'
    get_ranks(params[:ranktype], cat, page_no).to_json
  end
  
end
