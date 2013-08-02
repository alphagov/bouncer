RSpec::Matchers.define :be_valid_xml do
  match do |string|
    begin
      Nokogiri::XML::Document.parse(string) { |config| config.strict }
      true
    rescue Nokogiri::XML::SyntaxError
      false
    end
  end
end

RSpec::Matchers.define :be_valid_sitemap do
  match do |string|
    sitemap = Nokogiri::XML::Document.parse(string)
    schema = Nokogiri::XML::Schema.new(File.read(File.expand_path('../../features/sitemap.xsd', __FILE__)))

    schema.valid?(sitemap)
  end
end

RSpec::Matchers.define :have_sitemap_entry_for do |url|
  match do |string|
    sitemap = Nokogiri::XML::Document.parse(string)
    !sitemap.xpath("/xmlns:urlset/xmlns:url/xmlns:loc[text()='#{url}']").empty?
  end
end
