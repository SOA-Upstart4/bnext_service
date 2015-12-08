require_relative 'spec_helper'
require_relative 'spec_answers'
require 'json'

describe 'Checking post articles to database' do
  # before do
  #  Article.delete_all
  # end

  ### Testing POST /api/v1/article/
  it 'should save article into DB' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = {
      title: '[專訪] 全球最大停車App創辦人：並非停車位不夠，只是你找不到',
      author: '李欣宜',
      date: '2015/10/27',
      link: 'http://www.bnext.com.tw/article/view/id/37797',
      tags: ['智慧城市', '車聯網', '停車應用', 'Parkme', 'Sam Friedman']
    }

    post '/api/v1/article', body.to_json, header
    last_response.must_be :created?
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
    JSON.parse(last_response.body).must_equal(JSON.parse('{}'))
  end

  ### Testing GET /api/v1/article?viewid=37805
  it 'should return specific article' do
    VCR.use_cassette('get_specific_article') do
      get '/api/v1/article?viewid=37805'
    end
    last_response.must_be :ok?
    JSON.parse(last_response.body).must_equal(JSON.parse(Answer::SPECIFIC_ARTICLE))
  end

  ### Testing GET /api/v1/article/filter?tags=
  it 'use tags to filter articles in database' do
    VCR.use_cassette('filter_tags_article') do
      get '/api/v1/article/filter?tags=parkme'
    end
    last_response.must_be :ok?
    JSON.parse(last_response.body).must_equal Answer::FILTER_ARTICLE
  end

  ### Testing GET /api/v1/article/filter?author=
  it 'use author to filter articles in database' do
    uri = '/api/v1/article/filter?author=李欣宜'
    uri.force_encoding('binary')
    uri = WEBrick::HTTPUtils.escape(uri)

    VCR.use_cassette('filter_author_article') do
      get uri
    end

    last_response.must_be :ok?
    JSON.parse(last_response.body).must_equal Answer::FILTER_ARTICLE
  end

  ### Testing GET /api/v1/article/filter?title=
  it 'use title to filter articles in database' do
    uri = '/api/v1/article/filter?title=專訪'
    uri.force_encoding('binary')
    uri = WEBrick::HTTPUtils.escape(uri)

    VCR.use_cassette('filter_title_article') do
      get uri
    end

    last_response.must_be :ok?
    JSON.parse(last_response.body).must_equal Answer::FILTER_ARTICLE
  end

  ### Testing GET /api/v1/article/filter?tags=&author=&title=
  it 'filter articles in database' do
    uri = '/api/v1/article/filter?tags=parkme&author=李欣宜&title=專訪'
    uri.force_encoding('binary')
    uri = WEBrick::HTTPUtils.escape(uri)

    VCR.use_cassette('filter_article') do
      get uri
    end

    last_response.must_be :ok?
    JSON.parse(last_response.body).must_equal Answer::FILTER_ARTICLE
  end

    ### Testing GET /api/v1/article/:id/
end
