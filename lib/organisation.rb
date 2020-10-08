require "site"

class Organisation < ActiveRecord::Base
  has_many :sites
end
