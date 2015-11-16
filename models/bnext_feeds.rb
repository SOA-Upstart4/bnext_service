require 'bnext_robot'
require 'json'

class Constants
  USAGE = "Bad request: the query format is '/api/v1/[dayrank | weekrank | feed?cat=___&page=___]'\n"
end

class RankList
  def initialize(rank)
    @rank = rank
  end

  def [](idx)
    @rank[idx]
  end

  def length
    @rank.length
  end

  def to_json
    if @rank.class == Array

      @rank.each do |feed_hash|
        keys = feed_hash.keys.map { |k| k.dup.force_encoding(Encoding::UTF_8) }
        values = feed_hash.values.map { |v| if v.class == String then v.force_encoding(Encoding::UTF_8) else v end }
        Hash[keys.zip(values)]
      end.to_json

      # ActiveSupport::JSON.decode(@rank)

    elsif @rank.class == Hash

      error_msg = "[Bad request] please check the category and the page no is rational\n\n\n"
      error_msg += "Page no   : should be a natural number, a.k.a. POSITIVE INTEGER, and cannot be too large.\n"
      error_msg += "Categories:\n"
      @rank.each do |k, v|
        error_msg += "\t\"#{v}\", for searching \"#{k}\"\n"
      end

    else
      error_msg = Constants::USAGE
    end
  end
end

class RankFeeds
  attr_reader :type, :category, :page, :rank

  def initialize(type, category = '', page = '')
    @type = type
    @category = category
    @page = page
    _load_ranks
  end

  def self.fetch(type, category, page)
    RankFeeds.new(type, category, page).rank
  end

  private

  def _load_ranks
    bnext_robot = BNextRobot.new
    case @type

      when 'weekrank'
        @rank = RankList.new(bnext_robot.week_rank_feeds.map(&:to_hash))

      when 'dayrank'
        @rank = RankList.new(bnext_robot.day_rank_feeds.map(&:to_hash))

      when 'feed'
        feed_found = bnext_robot.get_feeds(@category, @page)
        if feed_found.length == 0
          cat_titles = bnext_robot.cats.keys.map { |k| k.dup.force_encoding(Encoding::UTF_8) }
          cat_urls = bnext_robot.cats.values.map { |v| v.dup.force_encoding(Encoding::UTF_8).split('/')[-1] }
          @rank = RankList.new(Hash[cat_titles.zip(cat_urls)])
        else
          @rank = RankList.new(feed_found.map(&:to_hash))
        end

      else
        @rank = RankList.new("BAD REQUEST")

    end
  end
end
