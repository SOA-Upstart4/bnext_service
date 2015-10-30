require_relative './model/bnext_feeds'

##
# Helpers for main Sinatra web application
module BNextHelpers
  def get_ranks(ranktype, category, page)
    RankFeeds.fetch(ranktype, category, page)
  rescue
    halt 404
  end

  def newest_feeds(categories)
    @newest = {}
    categories.map do |category|
      found = RankFeeds.fetch('feed', category, '1')
      [category, found[0]]
    end.to_h
  rescue
    halt 404
  end
end
