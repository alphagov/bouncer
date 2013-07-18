require 'host'
require 'mapping'

class Site < ActiveRecord::Base
  has_many :hosts
  has_many :mappings
end
