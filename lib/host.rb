class Host < Struct.new(:site, :host)
  def self.create(*args)
    new(*args).tap do |host|
      all << host
    end
  end

  def self.all
    @all ||= []
  end

  def self.destroy_all
    @all = []
  end

  def self.find_by(params)
    all.detect { |host| params.all? { |key, value| host[key] == value } }
  end

  def initialize(attributes)
    super *attributes.values_at(*members)
  end
end
