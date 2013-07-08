require 'host'
require 'mapping'

class Site
  def self.create
    new
  end

  def create_mapping(*args)
    Mapping.create(*args)
  end

  def create_host(attributes)
    Host.create(attributes.merge(site: self))
  end
end
