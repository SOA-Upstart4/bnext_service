require 'sinatra/base'
require_relative './model/bnext_feeds'

class BNextcadetApp < Sinatra::Base
  helpers do
    def get_ranks(ranktype)
      RankFeeds.fetch(ranktype)
    rescue
      halt 404
    end
  end

  get '/' do
    'This is version 1. Our Github homepage is : https://github.com/SOA-Upstart4/bnext_service'
  end

  get '/api/v1/cadet/:ranktype.json' do
    content_type :json
    get_ranks(params[:ranktype]).to_json
  end

  post '/api/v1/feed' do
    content_type :json
    begin
      req = JSON.parse(request.body.read)
    rescue
      halt 400
    end
  end
end
