require 'host'
require 'mapping'
require 'organisation'

class Site < ActiveRecord::Base
  belongs_to :organisation
  has_many :hosts
  has_many :mappings
end
