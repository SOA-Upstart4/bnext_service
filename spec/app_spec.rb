require_relative 'spec_helper'
require_relative '../application_controller'
require_relative 'spec_answers'
require 'json'

describe 'Getting the root of the service' do
  it 'should return ok' do
    get '/'
    last_response.must_be :ok?
    last_response.body.must_match(ApplicationController::ROOT_MSG)
  end
end

describe 'Getting rank_type information' do
  it 'should return week rank feeds' do
    VCR.use_cassette('week_rank') do
      get '/api/v1/weekrank'
    end
    last_response.must_be :ok?
    last_response.body.must_equal(Answer::WEEK_RANK)
  end

  it 'should return day rank feeds' do
    VCR.use_cassette('day_rank') do
      get '/api/v1/dayrank'
    end
    last_response.must_be :ok?
    last_response.body.must_equal(Answer::DAY_RANK)
  end

  it 'should return default feeds' do
    VCR.use_cassette('default_feed') do
      get '/api/v1/feed'
    end
    last_response.must_be :ok?
    last_response.body.must_equal(Answer::FEED_DEFAULT)
  end

  it 'should return internet page 4 feeds' do
    VCR.use_cassette('internet_page_4') do
      get '/api/v1/feed?cat=internet&page=4'
    end
    last_response.must_be :ok?
  end

  it 'should return bad request for wrong ranktype' do
    VCR.use_cassette('wrong_ranktype') do
      get "/api/v1/#{random_str(10)}"
    end
    last_response.body.must_equal(Constants::USAGE)
  end

  it 'should not find route 1' do
    VCR.use_cassette('wrong_route_1') do
      get "#{random_str(10)}"
    end
    last_response.must_be :not_found?
  end

  it 'should not find route 2' do
    VCR.use_cassette('wrong_route_2') do
      get "/api/#{random_str(10)}"
    end
    last_response.must_be :not_found?
  end
end

describe 'Checking newest feeds' do
  it 'should return tech & marketing feeds' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = { categories: ['tech', 'marketing'] }
    VCR.use_cassette('post_recent') do
      post '/api/v1/recent', body.to_json, header
    end
    last_response.must_be :ok?
    last_response.body.must_equal(Answer::RECENT)
  end

  it 'should return 400 for bad JSON formatting' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = random_str(15)
    post '/api/v1/recent', body, header
    last_response.must_be :bad_request?
  end

  it 'should return 404 for unknown category type' do
    header = { 'CONTENT_TYPE' => 'application/json' }
    body = { categories: [random_str(10)] }
    VCR.use_cassette('post_random') do
      post '/api/v1/recent', body.to_json, header
    end
    last_response.body.must_match(/null/)
  end
end
