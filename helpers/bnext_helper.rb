##
# Helpers for main Sinatra web application
module BNextHelpers
  def get_ranks(ranktype, category, page)
    RankFeeds.fetch(ranktype, category, page)
  rescue
    halt 404
  end
end
