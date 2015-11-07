require_relative 'spec_helper'
require_relative 'spec_answers'
require 'json'

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
