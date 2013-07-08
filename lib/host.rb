require 'record_collection'

class Host < Struct.new(:site, :host)
  def self.create(*args)
    new(*args).tap do |host|
      all << host
    end
  end

  def self.all
    @all ||= RecordCollection.new([])
  end

  def self.destroy_all
    @all = RecordCollection.new([])
  end

  def self.find_by(params)
    all.find_by(params)
  end

  def initialize(attributes)
    super *attributes.values_at(*members)
  end
end
