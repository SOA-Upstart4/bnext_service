require_relative 'spec_helper'
require_relative 'spec_answers'
require 'json'

describe 'Getting the root of the service' do
  it 'should return ok' do
    get '/'
    last_response.must_be :ok?
    last_response.body.must_match(ApplicationController::ROOT_MSG)
  end
end
