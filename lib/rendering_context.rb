class RenderingContext
  def initialize(attributes = {})
    @attributes = attributes
  end

  def render_binding
    OpenStruct.new(@attributes).instance_eval { binding }
  end
end
