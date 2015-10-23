require 'bnext_robot'
require 'json'

class RankList

  def initialize(rank)
    @rank = rank
  end

  def [](idx)
    @rank[idx]
  end

  def to_json
    @rank.each do |feed_hash|
      keys = feed_hash.keys.map { |k| k.dup.force_encoding(Encoding::UTF_8) }
      values = feed_hash.values.map { |v| if v.class == String then v.force_encoding(Encoding::UTF_8) else v end }
      Hash[keys.zip(values)]
    end.to_json
  end
end

class RankFeeds
  attr_reader :type, :rank

  def initialize(type)
    @type = type
    _load_ranks
  end

  def self.fetch(type)
    RankFeeds.new(type).rank
  end

  private

  def _load_ranks
    bnext_robot = BNextRobot.new
    case type
    when 'weekrank'
      @rank = RankList.new(bnext_robot.week_rank_feeds.map(&:to_hash))
    when 'dayrank'
      @rank = RankList.new(bnext_robot.day_rank_feeds.map(&:to_hash))
    when 'feed'
      puts 'Category list:'
      bnext_robot.cats.each do |title, link|
        puts "[#{title}]: #{link.split("/")[-1]}"
      end
      print 'Category: '
      cat = $stdin.readline.chomp
      print 'Page number: '
      page_no = $stdin.readline.chomp
      feed_found = bnext_robot.get_feeds(cat, page_no)
      if feed_found.length == 0
        puts 'Error: No result found. Check the input or internet connection.'
      else
        @rank = RankList.new(feed_found.map(&:to_hash))
      end
    end
  end

end
