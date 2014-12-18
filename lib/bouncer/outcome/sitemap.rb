module Bouncer
  module Outcome
    class Sitemap < Base
      MAXIMUM_SIZE = 50_000
      BATCH_SIZE   = 1_000 # Must be smaller than the MAXIMUM_SIZE, or too many could be added on the first loop

      def serve
        [200, { 'Content-Type' => 'application/xml' }, [build_sitemap.to_xml]]
      end

      def build_sitemap
        Nokogiri::XML::Builder.new do |xml|
          xml.urlset(xmlns: 'http://www.sitemaps.org/schemas/sitemap/0.9') do
            index = 0
            context.mappings.where(type: 'redirect').find_in_batches(batch_size: BATCH_SIZE) do |batch|
              batch.each do |mapping|
                url = Addressable::URI.parse(mapping.path).tap do |uri|
                  uri.scheme = 'http'
                  uri.host   = context.request.host
                end

                xml.url do
                  xml.loc url
                end
              end

              index = index + BATCH_SIZE
              # Stop looping (and querying and instantiating objects) when we
              # get to the maximum batch size
              break if index >= MAXIMUM_SIZE
            end
          end
        end
      end

    end
  end
end
