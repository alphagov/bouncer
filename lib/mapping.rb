require 'digest/sha1'

class Mapping < Struct.new(:path, :http_status, :new_url)
  def self.create(*args)
    new *args
  end

  def initialize(attributes)
    super *attributes.values_at(*members)
  end

  def path_hash
    Digest::SHA1.hexdigest(path)
  end
end
