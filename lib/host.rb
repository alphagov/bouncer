class Host < Struct.new(:host)
  def self.create(*args)
    new *args
  end

  def initialize(attributes)
    super *attributes.values_at(*members)
  end
end
