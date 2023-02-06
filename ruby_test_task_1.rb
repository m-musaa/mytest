require 'httparty'
require 'nokogiri'
require 'hashie'

class Scraper

  def scrape
    response = HTTParty.get('https://www.nasa.gov/api/2/ubernode/479003')
    result_hash = get_data_hash(response.body)
    puts result_hash
  end

  private

  def get_data_hash(response)
    data_hash = {}
    data = JSON.parse(response)
    data.extend Hashie::Extensions::DeepFind
    data_hash[:title] = data.deep_find('title')
    data_hash[:date] = data.deep_find('promo-date-time').split('T')[0]
    data_hash[:release_id] = data.deep_find('release-id')
    data_hash[:article] = find_article(data)
    data_hash
  end

  def find_article(data)
    article_html = data.deep_find('body')
    article_html = Nokogiri::HTML(article_html)
    article_html.css('.dnd-atom-wrapper').remove
    article_html.text.strip
  end
end

Scraper.new.scrape
