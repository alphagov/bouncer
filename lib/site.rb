require 'mapping'

class Site
  def self.create
    new
  end

  def create_mapping(*args)
    Mapping.create(*args)
  end
end
