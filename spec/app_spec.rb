require_relative 'spec_helper'
require 'json'

describe 'Getting the root of the service' do
  it 'should return ok' do
    get '/'
    last_response.must_be :ok?
    last_response.body.must_match(/homepage/i)
  end
end

describe 'Getting rank_type information' do
  it 'should return week rank feeds' do
    VCR.use_cassette('week_rank') do
      get '/api/v1/weekrank'
    end
    last_response.must_be :ok?
  end

  it 'should return day rank feeds' do
    VCR.use_cassette('day_rank') do
      get '/api/v1/dayrank'
    end
    last_response.must_be :ok?
  end

  it 'should return default feeds' do
    VCR.use_cassette('default_feed') do
      get '/api/v1/feed'
    end
    last_response.must_be :ok?
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
    last_response.body.must_match(Constants::USAGE)
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
