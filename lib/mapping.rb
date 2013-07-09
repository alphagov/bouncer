class Mapping < Struct.new(:path, :path_hash, :http_status, :new_url)
  def self.create(*args)
    new *args
  end

  def initialize(attributes)
    super *attributes.values_at(*members)
  end
end
