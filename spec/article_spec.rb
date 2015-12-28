require_relative 'spec_helper'
require_relative 'spec_answers'
require 'json'

describe 'Checking post articles to database' do
  before do
    Article.delete_all
  end

  it 'should save article into DB & then test filter' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      title: '[專訪] 全球最大停車App創辦人：並非停車位不夠，只是你找不到',
      author: '李欣宜',
      date: '2015/10/27',
      link: 'http://www.bnext.com.tw/article/view/id/37797',
      tags: ['智慧城市', '車聯網', '停車應用', 'Parkme', 'Sam Friedman']
    }
    ### Testing POST /api/v1/article/
    post '/api/v1/article', body.to_json, header
    last_response.must_be :created?

    ### Testing GET /api/v1/article/filter?tags=
    VCR.use_cassette('filter_tags_article') do
      get '/api/v1/article/filter?tags=parkme'
    end
    last_response.must_be :ok?

    ### Testing GET /api/v1/article/filter?author=
    uri = '/api/v1/article/filter?author=李欣宜'
    uri.force_encoding('binary')
    uri = WEBrick::HTTPUtils.escape(uri)

    VCR.use_cassette('filter_author_article') do
      get uri
    end
    last_response.must_be :ok?

    ### Testing GET /api/v1/article/filter?title=
    uri = '/api/v1/article/filter?title=專訪'
    uri.force_encoding('binary')
    uri = WEBrick::HTTPUtils.escape(uri)

    VCR.use_cassette('filter_title_article') do
      get uri
    end
    last_response.must_be :ok?

    ### Testing GET /api/v1/article/filter?tags=&author=&title=
    uri = '/api/v1/article/filter?tags=parkme&author=李欣宜&title=專訪'
    uri.force_encoding('binary')
    uri = WEBrick::HTTPUtils.escape(uri)

    VCR.use_cassette('filter_article') do
      get uri
    end
    last_response.must_be :ok?
=begin
    ### Testing GET /api/v1/article/filter?date_from=
    VCR.use_cassette('filter_date_from_article') do
      get '/api/v1/article/filter?date_from=2015/10/27'
    end
    last_response.must_be :ok?
=end
    ### Testing GET /api/v1/article/:id/
    most_recent_id = Article.order(:created_at).last
    id = most_recent_id[:id]
    VCR.use_cassette('get_article_by_db_id') do
      get "/api/v1/article/#{id}"
    end
    last_response.must_be :ok?
  end

  it 'should return 400 for bad JSON formatting' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = random_str(15)

    post '/api/v1/article', body, header
    last_response.must_be :bad_request?
  end

  ### Testing GET /api/v1/article
  it 'should return default article' do
    VCR.use_cassette('get_article') do
      get '/api/v1/article'
    end
    last_response.must_be :ok?
    JSON.parse(last_response.body).must_equal JSON.parse('{}')
  end

  ### Testing GET /api/v1/article?viewid=37805
  it 'should return article by viewid' do
    VCR.use_cassette('get_article_by_viewid') do
      get '/api/v1/article?viewid=37805'
    end
    last_response.must_be :ok?
    JSON.parse(last_response.body).must_equal(JSON.parse(Answer::SPECIFIC_ARTICLE))
  end

  ### Testing bad filtering article
  it 'should return empty when filtering articles in database' do
    ### no tags found
    VCR.use_cassette('filter_tags_notfound') do
      get '/api/v1/article/filter?tags=parkme'
    end
    last_response.must_be :ok?
    last_response.body.must_equal ''

    ### no title found
    uri = '/api/v1/article/filter?title=專訪'
    uri.force_encoding('binary')
    uri = WEBrick::HTTPUtils.escape(uri)

    VCR.use_cassette('filter_title_article') do
      get uri
    end
    last_response.must_be :ok?
    last_response.body.must_equal ''

    ### no author found
    uri = '/api/v1/article/filter?author=李欣宜'
    uri.force_encoding('binary')
    uri = WEBrick::HTTPUtils.escape(uri)

    VCR.use_cassette('filter_author_article') do
      get uri
    end
    last_response.must_be :ok?
    last_response.body.must_equal ''

    ### no title, author, tags found
    uri = '/api/v1/article/filter?tags=parkme&author=李欣宜&title=專訪'
    uri.force_encoding('binary')
    uri = WEBrick::HTTPUtils.escape(uri)

    VCR.use_cassette('filter_article') do
      get uri
    end
    last_response.must_be :ok?
    last_response.body.must_equal ''
  end

  ### Testing bad search by database id
  it 'should return article by database id' do
    most_recent_id = Article.order(:created_at).last
    VCR.use_cassette('get_article_by_db_id') do
      get "/api/v1/article/#{most_recent_id}"
    end
    last_response.must_be :ok?
    JSON.parse(last_response.body).must_equal JSON.parse('{}')
  end
end
