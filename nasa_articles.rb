
# Ruby test #1

require 'open-uri'
require 'nokogiri'
require 'json'


# Functioin: Scraping article data from www.nasa.gov 

def getNasaArticle(src_url)
    content_html = URI.open(src_url)
    parsed_data = Nokogiri::HTML.parse(content_html)
    article_id = parsed_data.to_s.scan(/\/ubernode\/(\d+)/i)[0][0]
    article_url = "https://www.nasa.gov/api/2/ubernode/#{article_id}"
    article_html = URI.open(article_url)
    json_data = Nokogiri::HTML.parse(article_html)
    obj = JSON.parse(json_data)

    result =  { 
        :title => obj["_source"]["title"],
        :date => obj["_source"]["promo-date-time"],
        :release_no => obj["_source"]["release-id"],
        :article => obj["_source"]["body"]
    }
end
puts getNasaArticle('https://www.nasa.gov/press-release/nasa-industry-to-collaborate-on-space-communications-by-2025')


