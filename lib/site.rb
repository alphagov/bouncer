require 'host'
require 'mapping'

class Site
  def self.create
    new
  end

  def mappings
    @mappings ||= []
  end

  def create_mapping(*args)
    Mapping.create(*args).tap do |mapping|
      mappings << mapping
    end
  end

  def create_host(attributes)
    Host.create(attributes.merge(site: self))
  end
end
