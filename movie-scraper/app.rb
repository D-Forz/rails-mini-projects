# frozen_string_literal: true

require 'net/http'
require 'nokogiri'
require 'yaml'

URL = 'https://www.imdb.com/chart/top/'

def scraper_imdb
  html_doc = Net::HTTP.get(URI(URL))
  doc = Nokogiri::HTML(html_doc)
  movies_url = doc.search('.titleColumn a').take(5)
  movies_url.map do |movie|
    uri = URI.parse(movie.attributes['href'].value)
    uri.scheme = 'https'
    uri.hostname = 'www.imdb.com'
    uri.to_s
  end
end

def scraper_movie(url) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
  doc = Nokogiri::HTML(Net::HTTP.get(URI(url)))
  p doc
  movie = {}
  movie[:title] = doc.search('h1').text
  p movie[:title]
  movie[:year] = doc.search('.sc-8c396aa2-1').first.text.to_i
  movie[:storyline] = doc.search('.sc-16ede01-1').children.text
  movie[:director] = doc.search('.ipc-metadata-list__item:contains("Director") a').first.text
  class_name = '.ipc-metadata-list__item:contains("Stars") a.ipc-metadata-list-item__list-content-item'
  movie[:stars] = doc.search(class_name).map(&:text).uniq
  movie
end

movies = scraper_imdb.map do |url|
  puts "Scraping url: #{url}"
  scraper_movie(url)
end

File.open('movies.yml', 'w') do |file|
  file.write(movies.to_yaml)
end
