##
# Helpers for main Sinatra web application
module TrendHelpers
  def newest_feeds(categories)
    categories.map do |category|
      found = RankFeeds.fetch('feed', category, '1')
      [category, found[0]]
    end.to_h
  rescue
    halt 404
  end
end
