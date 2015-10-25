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

  get '/api/v1/cadet/:ranktype.?:cat?.?:page?json' do
    content_type :json
    cat = params[:cat] || ''
    page = params[:page] || ''
    get_ranks(params[:ranktype], cat, page).to_json
  end
end
