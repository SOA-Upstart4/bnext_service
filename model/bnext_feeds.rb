require 'bnext_robot'
require 'json'

class RankList
  def []=(title, url)
    @rank ||= {}
    @rank[title] = url
  end

  def to_json
    @rank.map do |title, url|
      { 'title' => title, 'url' => url }
    end.to_json
  end
end

class RankFeeds
  attr_reader :type, :rank

  def initialize(type)
    @type = type
    _load_ranks
  end

  private

  def _load_ranks
    rank = RankList.new
    bnext_robot = BNextRobot.new
    case type
    when 'weekrank'
      bnext_robot.show_week_rank.each do |feed|
        rank[feed.title] = feed.link
      end
    when 'dayrank'
      bnext_robot.show_day_rank.each do |feed|
        rank[feed.title] = feed.link
      end
    when 'feed'
      puts 'Category list:'
      puts '[網路]: internet  [科技]: tech    [行銷]: marketing'
      puts '[創業]: startup   [人物]: people  [技能]: skill'
      print 'Category: '
      cat = $stdin.readline.chomp
      print 'Page number: '
      page_no = $stdin.readline.chomp
      feed_found = bnext_robot.get_feeds(cat, page_no)
      if feed_found.length == 0
        puts 'Error: No result found. Check the input or internet connection.'
      else
        puts "#{feed_found}"
      end
    end
  end
end
