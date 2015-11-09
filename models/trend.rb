require 'sinatra'
require 'sinatra/activerecord'
require_relative '../config/environments'

class Trend < ActiveRecord::Base
end
