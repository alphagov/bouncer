class StatusRenderer
  def initialize
    @templates = {}
  end

  def template_content(status)
    filename = File.expand_path("../../templates/#{status}.erb", __FILE__)
    File.read(filename) if File.exist?(filename)
  end

  ##
  # Get the ERB instance for this status
  def [](status)
    @templates[status.to_s] ||= (template_str = template_content(status)) && ERB.new(template_str)
  end

  def render(context, status)
    template = self[status]
    template.result(context.render_binding)
  end
end
