require 'sinatra'
require 'sinatra/activerecord'
require_relative '../config/environments'

class Article < ActiveRecord::Base
end
